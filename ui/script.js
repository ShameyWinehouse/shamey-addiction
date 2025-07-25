
$(document).ready(function () {
  var addiction = 0;
  var show = false;
  window.addEventListener("message", function (event) {
    if (event.data.showhud == undefined) {
      addiction = event.data.addiction;
      setProgressAddiction(addiction, '.progress-addiction');
    }
    if (event.data.showhud == true || event.data.showhud == false) {
      show = event.data.showhud;
    }
    if (show == true) {
      $('#addiction-hud-container').show();
      setProgressAddiction(addiction, '.progress-addiction');
    } else {
      $('#addiction-hud-container').hide();
    }
  });

  // Functions

  function setProgressAddiction(percent, element) {
	  if(percent == undefined || percent <= 0){
		  percent = 0;
	  }
    var circle = document.querySelector(element);
    var radius = circle.r.baseVal.value;
    var circumference = radius * 2 * Math.PI;
    var html = $(element).parent().parent().find('span');
    var x4 = document.getElementById("test4");
    if (percent < 60) {
      x4.style.stroke = "#fff";
    }
    if (percent >= 60) {
      x4.style.stroke = "#ffaf02";
    }
    if (percent >= 80) {
      x4.style.stroke = " #FF0245";
    }

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = `${circumference}`;

    const offset = circumference - ((-percent * 100) / 100) / 100 * circumference;
    circle.style.strokeDashoffset = -offset;

    html.text(Math.round(percent));
  }

});
