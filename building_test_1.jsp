<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>	
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">	
<meta http-equiv="X-UA-Compatible" content="ie=edge">	
<title>Insert title here</title>
<div data-role="content">
		<video width="320" height="240"  id="videoElement"
		 autoplay muted playsinline style='position: fixed; top:0; left: 0; display: block'></video>
		<div id="label-container" style='position: fixed; top: 50%; left:0; display: block'></div>
	</div>>
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
<script src="https://cdn.jsdelivr.net/npm/@teachablemachine/image@0.8/dist/teachablemachine-image.min.js"></script>
<script type="text/javascript">

var video = document.querySelector("#videoElement");
var stopVideo = document.querySelector("#stop");
var videoSelect=new Array();
// 디바이스 정보를 가져오기 위한 콜백 함수.     gotDevices -> getDevices -> getStream
getStream().then(getDevices).then(gotDevices);

// 접근 가능한 미디어 입출력장치의 리스트를 가져옴.
function getDevices() {
  // AFAICT in Safari this only gets default devices until gUM is called :/
  return navigator.mediaDevices.enumerateDevices();
}

// 디바이스 장치에 대한 정보를 가져옴.
function gotDevices(deviceInfos) 
{
	
	window.deviceInfos = deviceInfos; // make available to console
	console.log('Available input and output devices:', deviceInfos);
	// deviceINfo 에서 deviceINfos 에 대한 값을 가져옴.
	for (var deviceInfo of deviceInfos) 
	{
		if (deviceInfo.kind === 'videoinput') 
		{
			//videoselect 에 deviceinfo 에서 가져온 deviceid 를 push 함.
			videoSelect.push(deviceInfo.deviceId);
		}
	}	
	getStream();
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

//에러 처리 구문
function handleError(error) {
  console.error('Error: ', error);
}


// teachable machine 코드 시작
const URL = "./my_model/";

    let model, webcam, labelContainer, maxPredictions;
    //video = document.querySelector("#videoElement");
    
    // Load the image model and setup the webcam
    
async function Init()
{
	const modelURL = URL + "model.json";
	const metadataURL = URL + "metadata.json";
	
	model = await tmImage.load(modelURL, metadataURL);
	maxPredictions = model.getTotalClasses();
	
	/* const flip = true;
	webcam = new tmImage.Webcam($(window).width(),$(window).height(), flip);
	await webcam.setup();
	await webcam.play();*/
	window.requestAnimationFrame(loop); 
	
	//document.getElementById("webcam-container").appendChild(webcam.canvas);
	labelContainer = document.getElementById("label-container");
	for(let i = 0; i < maxPredictions; i++){
		labelContainer.appendChild(document.createElement("div"));
	}
}

    async function loop() {
        //webcam.update(); // update the webcam frame
        await predict();
        window.requestAnimationFrame(loop);
    }
    
    async function predict() {
        // predict can take in an image, video or canvas html element
        const prediction = await model.predict(video);
        
        for (let i = 0; i < maxPredictions; i++) {
            const classPrediction =
                prediction[i].className + ": " + prediction[i].probability.toFixed(2);
            labelContainer.childNodes[i].innerHTML = classPrediction;
        }
       
      }
    
  </script>
</head>
<body>

  <script>
  	Init();
  </script>
</body>


</html>
