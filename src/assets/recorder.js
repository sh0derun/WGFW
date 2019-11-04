class Recorder {

    constructor(canvasId) {
    	this.canvas = document.getElementById(canvasId);
    	this.mediaRecorder = this.piCreateMediaRecorder(function(flag){
    	}, this.canvas);
    	if(this.mediaRecorder === null){
    		alert("MediaRecorder API is not supported in this browser");
    	}
    }

    piCanMediaRecorded() {
        if (typeof window.MediaRecorder !== 'function' || typeof this.canvas.captureStream !== 'function') {
            return false;
        }
        return true;
    }

    piCreateMediaRecorder(isRecordingCallback) {
        if (this.piCanMediaRecorded(this.canvas) == false) {
            return null;
        }

        var options = {
            audioBitsPerSecond: 0,
            videoBitsPerSecond: 7500000
        };
        if (MediaRecorder.isTypeSupported('video/webm;codecs=vp9')) options.mimeType = 'video/webm; codecs=vp9';
        if (MediaRecorder.isTypeSupported('video/webm;codecs=vp8')) options.mimeType = 'video/webm; codecs=vp8';
        else options.mimeType = 'video/webm;';

        var mediaRecorder = new MediaRecorder(this.canvas.captureStream(), options);
        var chunks = [];

        mediaRecorder.ondataavailable = function(e) {
            if (e.data.size > 0) {
                chunks.push(e.data);
            }
        };

        mediaRecorder.onstart = function() {
            isRecordingCallback(true);
        };

        mediaRecorder.onstop = function() {
            isRecordingCallback(false);
            let blob = new Blob(chunks, {
                type: "video/webm"
            });
            chunks = [];
            let videoURL = window.URL.createObjectURL(blob);
            let url = window.URL.createObjectURL(blob);
            let a = document.createElement("a");
            document.body.appendChild(a);
            a.style = "display: none";
            a.href = url;
            a.download = "capture.webm";
            a.click();
            window.URL.revokeObjectURL(url);
        };

        return mediaRecorder;
    }

}