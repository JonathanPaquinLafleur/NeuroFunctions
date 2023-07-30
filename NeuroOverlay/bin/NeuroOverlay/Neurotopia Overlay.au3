If Not(ProcessExists ("BrainFunction_PIDSuspend.exe")) Then
   Run("service/BrainFunction_PIDSuspend.exe","", @SW_HIDE)
EndIf
$PID = Run("client.exe")
Sleep(2000)
ProcessWaitClose($PID)
ProcessClose("BrainFunction_PIDSuspend.exe")