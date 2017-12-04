window.onload = function() {
  document.getElementById("def_style").href = "/static/css/" + localStorage.getItem("maidchan-active");
};

function setTheme(theme) {
  if(theme == "light") {
    localStorage.setItem("maidchan-active", "maidchan.css");
  } else if(theme == "dark") {
    localStorage.setItem("maidchan-active", "maidchan-dark.css");
  }
  location.reload();
}
