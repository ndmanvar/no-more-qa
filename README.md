No More QA
===================

This project intends on removing the need to write automated tests.
Founders: Kristian Meier, Neil Manvar

Strategy/Approach:
------------------



To setup:
---------

Run backend:
```
$ npm install
$ cd backend
$ node backend.js
```

Open app in browser:
```
$ open app.html
```

Install and setup mysql (localhost, default port). Create events table (See events.png).

Obtain sessionId from either browser instance, backend or table.

Use it as parameter to Ruby script:
```
$ cd test_creation
$ bundle install
$ ruby create_test.rb <SESSION_ID> && ruby spec_to_test.rb
```

Problems NM-QA is solving:
- Scaling Testing/T.A.
- Application Testability
