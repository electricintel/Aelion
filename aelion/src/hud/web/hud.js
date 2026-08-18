document.addEventListener('DOMContentLoaded', () => {
    const stream = document.getElementById('stream-output');
    const engineOut = document.getElementById('engine-output-text');

    function addStreamMessage(msg) {
        stream.textContent += msg + \"\\n\";
    }

    function addEngineOutput(msg) {
        engineOut.textContent += msg + \"\\n\";
    }

    addStreamMessage(\"HUD initialized.\");
    addEngineOutput(\"Awaiting engine data...\");
});
