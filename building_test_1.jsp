<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">	
<meta http-equiv="X-UA-Compatible" content="ie=edge">	
<title>Insert title here</title>

<style>
@charset "UTF-8";
html,
body {
  margin: 0;
  padding: 0;
}

html {
  height: 50%;
}

body {
  font-family: Helvetica, Arial, sans-serif;
  min-height: 100%;
  display: grid;
  grid-template-rows: 1fr auto;
}

header {
  background: #f0293e;
  color: #fff;
  text-align: center;
}
main {
  background: #ffffff;
  min-height: 80vh;
}

.controls {
  text-align: center;
  padding: 0.5em 0;
  background: #333e5a;
}

video {
  width: 80%;
  max-width: 550px;
  display: block;
  margin: 0 auto;
}
#errorMsg {
	height : 100px;
}


</style>
<script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@1.3.1/dist/tf.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@teachablemachine/image@0.8.3/dist/teachablemachine-image.min.js"></script>
<script type="text/javascript">


// 모바일 디바이스 접근 권한 설정 (비디오)
let video = document.querySelector('videoElement');
var constraints = window.constraints = {
  audio: false,
  video: true
};
var errorElement = document.querySelector('#errorMsg');

navigator.mediaDevices.getUserMedia(constraints)
.then(function(stream) {
  var videoTracks = stream.getVideoTracks();
  console.log('Got stream with constraints:', constraints);
  console.log('Using video device: ' + videoTracks[0].label);
  stream.onremovetrack = function() {
    console.log('Stream ended');
  };
  window.stream = stream; // make variable available to browser console
  video.srcObject = stream;
})
.catch(function(error) {
  if (error.name === 'ConstraintNotSatisfiedError') {
    errorMsg('The resolution ' + constraints.video.width.exact + 'x' +
        constraints.video.width.exact + ' px is not supported by your device.');
  } else if (error.name === 'PermissionDeniedError') {
    errorMsg('Permissions have not been granted to use your camera and ' +
      'microphone, you need to allow the page access to your devices in ' +
      'order for the demo to work.');
  }
  errorMsg('getUserMedia error: ' + error.name, error);
});

function errorMsg(msg, error) {
  errorElement.innerHTML += '<p>' + msg + '</p>';
  if (typeof error !== 'undefined') {
    console.error(error);
  }
}

function getStream() 
{
	//비디오 스트리밍 서비스
	if (window.stream) 
	{
		window.stream.getTracks().forEach(track => {
			track.stop();
		});
	}

	var audioSource = "";
	var videoSource = "";
	
	// videoSelect 의 길이가 0보다 크면 if문으로 빠져서 실행. (fullscreen API)
	if(videoSelect.length>0)
		videoSource=videoSelect[videoSelect.length-1];
	const constraints = 
	{
			//동시에 audio와 video 소스를 가져오기 위함.
		audio: {deviceId: audioSource ? {exact: audioSource} : undefined},
		video: {deviceId: videoSource ? {exact: videoSource} : undefined}
	};
	// constraints 에 감지된 디바이스 들의 정보의 권한요청을 함.
	return navigator.mediaDevices.getUserMedia(constraints).
		then(gotStream).catch(handleError);
}

function gotStream(stream) {
  window.stream = stream; // make stream available to console

  video.srcObject = stream;
}


function handleError(error) {
  console.error('Error: ', error);
}

// teachable machine 코드 시작

    // More API functions here:
    // https://github.com/googlecreativelab/teachablemachine-community/tree/master/libraries/image

    // the link to your model provided by Teachable Machine export panel
    const URL = "./my_model/";

    let model, webcam, labelContainer, maxPredictions;
    video = document.querySelector("#videoElement");
    
    // Load the image model and setup the webcam
    async function init() {
        const modelURL = URL + "model.json";
        const metadataURL = URL + "metadata.json";

        // load the model and metadata
        // Refer to tmImage.loadFromFiles() in the API to support files from a file picker
        // or files from your local hard drive
        // Note: the pose library adds "tmImage" object to your window (window.tmImage)
        model = await tmImage.load(modelURL, metadataURL);
        maxPredictions = model.getTotalClasses();

        // Convenience function to setup a webcam
        const flip = true; // whether to flip the webcam
        webcam = new tmImage.Webcam(400, 300, flip); // width, height, flip
        await webcam.setup(); // request access to the webcam
        await webcam.play();
        window.requestAnimationFrame(loop);

        // append elements to the DOM
        document.getElementById("webcam-container").appendChild(webcam.canvas);
        labelContainer = document.getElementById("label-container");
        for (let i = 0; i < maxPredictions; i++) { // and class labels
            labelContainer.appendChild(document.createElement("div"));
        }
    }

    async function loop() {
        webcam.update(); // update the webcam frame
        await predict();
        window.requestAnimationFrame(loop);
    }
    
    async function predict() {
        // predict can take in an image, video or canvas html element
        const prediction = await model.predict(webcam.canvas);
        
        for (let i = 0; i < maxPredictions; i++) {
            const classPrediction =
                prediction[i].className + ": " + prediction[i].probability.toFixed(2);
            labelContainer.childNodes[i].innerHTML = classPrediction;
        }
        /*
        for (let i = 0; i < maxPredictions; i++) {
        	if (prediction[0].className == "쉐덕관" && prediction[0].probability.toFixed(2) >= 0.90) {
                labelContainer.childNodes[0].innerHTML = "여기는 쉐덕관";
              } 
            else if (prediction[1].className == "감부열관" && prediction[1].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 감부열관";
            } 
            else if (prediction[2].className == "바우어관" && prediction[2].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 바우어관";
            } 
            else if (prediction[3].className == "평생교육원" && prediction[3].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 평생교육원";
            } 
            else if (prediction[4].className == "수산관" && prediction[4].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 수산관";
            } 
            else if (prediction[5].className == "비사관" && prediction[5].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 비사관";
            } 
            else if (prediction[6].className == "동서문학관" && prediction[6].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 동서문학관";
            } 
            else if (prediction[7].className == "본관" && prediction[7].probability.toFixed(2) >= 0.90) {
              labelContainer.childNodes[0].innerHTML = "여기는 본관";
            } else {
            	labelContainer.childNodes[0].innerHTML = "장소를 새로 등록해야되는 곳 입니다.";
            }	
        }
        */
      }
    
  </script>
</head>
<body>

  <div>Teachable Machine Image Model</div>
  <script type="text/javascript">
	init();
  </script>
  <div id="webcam-container"></div>
  <div id="label-container"></div>  
      
   <video width="320" height="240"  id="videoElement" autoplay muted playsinline style='position: fixed; top:0; left: 0; display: block'></video>
		<div id ='canvasview' style='position: absolute; top:0; left:0;'>
			<canvas id='canvas' width='512' height='512'  oncontextmenu='return false;'>		
			</canvas>
		</div>
   <div id = "errorMsg" ></div>
  
</body>


</html>