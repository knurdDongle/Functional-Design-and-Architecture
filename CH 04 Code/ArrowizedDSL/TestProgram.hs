module TestProgram where

import Control.Monad.Free

import ControllerDSL as C
import InfrastructureDSL as I
import ScriptingDSL as S
import Control
import Interpreters

logReceiver :: Receiver
logReceiver = \v -> print v

alarmReceiver :: Receiver
alarmReceiver = \v -> print ("WARNING!", v)


controlProgram :: ControlProgram ()
controlProgram = do
    logMessage "[INF]" "Control program started."
    result1 <- evalScript (controllerScript startBoosters)
    result2 <- evalScript (controllerScript startRotaryEngines)
    checkResult result1
    checkResult result2
    logMessage "[INF]" "Control program finished."
    
logMessage :: String -> String -> ControlProgram ()
logMessage severity str = do
    time <- evalScript (infrastructureScript getCurrentTime)
    let msg = show (time, severity, str)
    evalScript (infrastructureScript (logMsg msg))
    
startBoosters :: ControllerScript CommandResult
startBoosters = run (Controller "boosters") (Command "start")

startRotaryEngines :: ControllerScript CommandResult
startRotaryEngines = run (Controller "rotary engines") (Command "start")
        
checkResult :: CommandResult -> ControlProgram ()
checkResult (Left failed) = do
    let errorMsg = "Start engines failed"
    logMessage "[ERR]" errorMsg
    evalScript (infrastructureScript (alarm errorMsg))
checkResult (Right succeeded) = 
    logMessage "[INF]" "Start engines succeeded"

    

    
test = interpretControlProgram controlProgram