window.uid = getGuid();

assignTestIDs();

window.onclick = function (event) {
    var element = getTestIDInfo(event);
    if (element.testId) {
        console.log('Click on : ' + element.testId.value);
        sendEvent({
            type: 'click',
            testId: element.testId.value,
            safe: element.safe
        });
    }

    // TODO: Send to database / aggregate
}

// TODO: hover, etc.

window.onkeypress = function (event) {
    var element = getTestIDInfo(event);
    if (element.testId) {
        console.log('Sending key : ' + event.key + ' to : ' + element.testId.value);
        sendEvent({
            type: 'key',
            testId: element.testId.value,
            key: event.key,
            safe: element.safe
        });
    }
}

function assignTestIDs() {
    var elements = document.getElementsByTagName("*"),
        counter = 1,
        href = window.location.href,
        route = href.substr(href.lastIndexOf('/') + 1);

    for (var i = 0, max = elements.length; i < max; i++) {
        //  TODO: only assign testId to certain types of elements (e.g. not html, br) that will be interacted with
        var testId = elements[i].getAttribute('id');
        if (testId === null) {
            elements[i].setAttribute('id', route + "-" + counter.toString());
            counter++;
        } else {
            if (isNumeric(testId)) console.log("Error: Don't use Integers as id homie.");
            // if (isNumeric(testId)) throw ("Error: Don't use Integers as id homie.");
            // TODO: handle properly, since we will probably want to support the use of id's later, since adding id increases payload
        }
    }
}

// TODO: figure out if we need this / what to do with it
function getTestIDInfo(event) {
    var testId = event.target.attributes.getNamedItem('id');

    return {
        testId: testId,
        safe: !!testId
    };
}

function sendEvent(event) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'http://localhost:3000/event', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    // xhr.setRequestHeader('Access-Control-Allow-Origin', '*');
    xhr.onload = function () {
        // do something to response
        console.log(this.responseText);
    };

    // TODO: refactoring and send as object. Will need to possibly escape as well
    xhr.send('type=' + event.type + '&key=' + event.key + '&uid=' + window.uid + '&testId=' + event.testId + '&safe=' + (event.safe ? '1' : '0'));
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

function isNumeric(num) {
    return !isNaN(num);
}
