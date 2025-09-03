; -----------------------------------------------------------------------------
; Copyright (c) 2025 SpeedruneerOff
;
; This source code is licensed under the MIT License.
; See the LICENSE file in the project root for full license information.
; -----------------------------------------------------------------------------

; proc.s

dd functions

functions:
    dd new_process
    dd get_process_flags
    dd send_process

new_process:
    ret

dd DRV_FUNC_END



get_process_flags:
    ret

dd DRV_FUNC_END



send_process:
    ret

dd DRV_FUNC_END



dd END_DRV