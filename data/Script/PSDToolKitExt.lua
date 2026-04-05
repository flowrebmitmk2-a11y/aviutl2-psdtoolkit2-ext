--- PSDToolKitExt.lua
--- PSDToolKit のカスタム拡張（本体ファイルを変更せずに機能追加）
--- require("PSDToolKitExt") で使用。PSDToolKit モジュールを in-place で拡張して返す。
---
--- 注意: 本ファイルが PSDToolKit 本体より先にロードされていない場合、
---       最初の1フレームで set_voice / set_layer_selector_overwriter の
---       ラップが間に合わない可能性があります（2フレーム目以降は正常）。

local M               = require("PSDToolKit")
local CharacterID     = require("PSDToolKit.CharacterID")
local FrameState      = require("PSDToolKit.FrameState")
local SubObjectStates = require("PSDToolKit.SubObjectStates")
local OverwriterStates = require("PSDToolKit.OverwriterStates")

-- 多重適用防止
if M._ext_loaded then return M end
M._ext_loaded = true

-- ────────────────────────────────────────────────────────────────
-- 分離タイミングストア
--   voice_sub  : セリフ準備が登録したタイミング情報
--   overwr_sub : パーツ上書きが登録したタイミング情報
-- ────────────────────────────────────────────────────────────────
local voice_sub  = {}  -- frame -> { id_key -> timing }
local overwr_sub = {}  -- frame -> { id_key -> timing }

local function sub_set(store, id, layer, obj)
    local frame = FrameState.get_current_frame()
    FrameState.track_frame_access(frame)
    if not store[frame] then store[frame] = {} end
    CharacterID.set(store[frame], id, layer, {
        time       = obj.time,
        frame      = obj.frame,
        totaltime  = obj.totaltime,
        totalframe = obj.totalframe,
    })
end

local function sub_get(store, id)
    local frame = FrameState.get_current_frame()
    local fs = store[frame]
    if not fs then return nil end
    return CharacterID.get(fs, id)
end

-- ── FrameState フック：古いフレームのクリーンアップ ──────────────
local _orig_get_ftc = FrameState.get_frames_to_cleanup
FrameState.get_frames_to_cleanup = function()
    local frames = _orig_get_ftc()
    for _, f in ipairs(frames) do
        voice_sub[f]  = nil
        overwr_sub[f] = nil
    end
    return frames
end

local _orig_clear_all_frames = FrameState.clear_all_frames
FrameState.clear_all_frames = function()
    _orig_clear_all_frames()
    voice_sub  = {}
    overwr_sub = {}
end

-- ── new_frame ラップ：現フレームのクリーンアップ ─────────────────
local _orig_new_frame = M.new_frame
M.new_frame = function()
    local frame = FrameState.get_current_frame()
    _orig_new_frame()
    -- 再レンダリング時に古いタイミングデータが残らないよう現フレームをクリア
    voice_sub[frame]  = nil
    overwr_sub[frame] = nil
    -- p=0 上書きが再描画時に反映されるよう OverwriterStates もクリア
    OverwriterStates:cleanup_frame(frame)
end

-- ── draw_psd ラップ：完全透明時は PSD レンダリングをスキップ ─────
local _orig_draw_psd = M.draw_psd
M.draw_psd = function(obj)
    if obj.alpha <= 0 then return end
    _orig_draw_psd(obj)
end

-- ── set_voice ラップ：セリフ準備のタイミングを別途記録 ───────────
local _orig_set_voice = M.set_voice
M.set_voice = function(id, text, audio, obj_)
    _orig_set_voice(id, text, audio, obj_)
    sub_set(voice_sub, id, obj_.layer, obj_)
end

-- ── set_layer_selector_overwriter ラップ：パーツ上書きを別途記録 ──
local _orig_set_lso = M.set_layer_selector_overwriter
M.set_layer_selector_overwriter = function(id, values, obj_)
    _orig_set_lso(id, values, obj_)
    sub_set(overwr_sub, id, obj_.layer, obj_)
end

-- ────────────────────────────────────────────────────────────────
-- enter_exit_ext
--   opts.subobj_source
--     0 = 両方（標準動作：SubObjectStates をそのまま使用）
--     1 = パーツ上書きのみ
--     2 = セリフ準備のみ
-- ────────────────────────────────────────────────────────────────
M.enter_exit_ext = function(opts, obj)
    local src = opts.subobj_source or 0
    if src == 0 then
        M.enter_exit(opts, obj)
        return
    end
    -- SubObjectStates.get を一時差し替えて enter_exit を呼ぶ
    local store = src == 1 and overwr_sub or voice_sub
    local _orig_get = SubObjectStates.get
    SubObjectStates.get = function(self, id)
        return sub_get(store, id)
    end
    local ok, err = pcall(M.enter_exit, opts, obj)
    SubObjectStates.get = _orig_get  -- 必ず元に戻す
    if not ok then error(err, 2) end
end

return M
