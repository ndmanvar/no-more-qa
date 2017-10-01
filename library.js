window.uid = getGuid();

window.onclick = function (event) {
    var element = getTestID(event);
    if (element) {
        console.log('Click on : ' + element.value);
    }

    sendEvent({
        type: 'click',
        testId: element.value
    });

    // TODO: Send to database / aggregate
}

window.onkeypress = function (event) {
    var element = getTestID(event);
    if (element) {
        console.log('Sending key : ' + event.key + ' to : ' + element.value);
    }

    sendEvent({
        type: 'key',
        testId: element.value,
        key: event.key
    });
}

function getTestID(event) {
    return event.target.attributes.getNamedItem('test-id');
}

function sendEvent(event) {
    event.uid = window.uid;

    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'http://localhost:3000/event', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    // xhr.setRequestHeader('Access-Control-Allow-Origin', '*');
    xhr.onload = function () {
        // do something to response
        console.log(this.responseText);
    };
    xhr.send('type=' + event.type + '&key=' + event.key + '&uid=' + event.uid + '&testId=' + event.testId);
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
