window.onclick = function (event) {

    var element = event.target.attributes.getNamedItem('test-id')
    if (element) {
        console.log('Click on : ' + element.value)
    }

    // TODO: Send to database / aggregate
 }

window.onkeypress = function () {

    var element = event.target.attributes.getNamedItem('test-id')
    // debugger;
    if (element) {
        console.log('Sending key : ' + event.key + ' to : ' + element.value)
    }

}

// TODO: be smarter about how we are identifying uniqueness, i.e. user info
function getGuid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

window.uid = getGuid();
