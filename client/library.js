!function (a, b) {
    var c = window;
    c.SessionStack = a,
    c[a] = c[a] || function () {
        c[a].q = c[a].q || [],
        c[a]
            .q
            .push(arguments)
    },
    c[a].t = b;
    var d = document.createElement("script");
    d.async = 1,
    d.src = "https://cdn.sessionstack.com/sessionstack.js";
    var e = document.getElementsByTagName("script")[0];
    e
        .parentNode
        .insertBefore(d, e);
}("sessionstack", "7657507674e04f929b1ba142269ea82a");

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

function isNumeric(num) {
    return !isNaN(num);
}

assignTestIDs()
