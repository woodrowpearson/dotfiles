const http = require('http');
const https = require('https');
const uuidv4 = require('uuid').v4;
let orgid = '270e9c4c-eab4-4c47-984c-fb1822b4a225';

let cookieHeader = 'sessionKey=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; intercom-device-id-lupk8zyo=6bc357c4-9704-4080-80b1-6859d89ae5ac; cf_clearance=5Rdq0fdaPyYeCGBX4S7xOzE9EWhcr3XOdb4I.ozsLno-1692175430-0-1-2d4a0212.6bfde5ec.7a4b5df2-0.2.1692175430; __cf_bm=pifEHioCtERKOoFQI.MiDxZh5TE5yV4rpAECfAYqmPM-1692176483-0-AaKkdlE7rshGa+tipvJycM4z/KQVlolUaaCA/WKEKzpQdvKdRLqDL2UxIWe+g2pQEHb7NQa6PHlpRoQWPWA3CG0=; intercom-session-lupk8zyo=MXRLd29GTTU1dHlydGwvbmwwOG5BOVJyL1htb0dpbjlQQ3p1V0dSbUh5dExXSWJUek5uTFh2enVqaXZoRXlxUy0tMVVQdjJOQkozNHR1cm1RQnZ5UVozdz09--3459613846afe79f5b76b3e28a8e5a57d042fb26';

let UAarray = [
	'Mozilla/5.0 (X11; U; Linux armv7l like Android; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/533.2+ Kindle/3.0+',
	'Mozilla/5.0 (Linux; U; Android 1.6; en-us; SonyEricssonX10i Build/R1AA056) AppleWebKit/528.5  (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1',
	'Mozilla/5.0 (Linux; U; Android 2.2; en-us; Sprint APA9292KT Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
	'Mozilla/5.0 (Android 6.0.1; Mobile; rv:48.0) Gecko/48.0 Firefox/48.0',
	'Mozilla/5.0 (Linux; U; Android 3.0.1; en-us; GT-P7100 Build/HRI83) AppleWebkit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13',
	'Mozilla/5.0 (iPod; U; CPU iPhone OS 3_1_1 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Mobile/7C145',
	'Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_0 like Mac OS X; en-us) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/5A347 Safari/525.200',
	'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25',
	'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; da-dk) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5',
	'Mozilla/5.0 (iPod; U; CPU iPhone OS 3_1_1 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Mobile/7C145',
	'PLAP (PLAP; PLAP; GET PREGNANT; PLAP) PLAP (PLAP PLAP PLAP GET PREGNANT CLAUDE) PLAP'
];
let ua = UAarray[Math.floor(Math.random() * UAarray.length)];

https.get('https://claude.ai/api/organizations', {headers: {'Cookie': cookieHeader, 'User-Agent': ua}}, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    const jsonData = JSON.parse(data);
	if (typeof(jsonData.error) !== 'undefined') {
		throw new Error(JSON.stringify(jsonData));
	}
    orgid = jsonData[0].uuid;
  });

}).on("error", (err) => {
  console.log("Error: " + err.message);
});

const server = http.createServer((req, res) => {
  if (req.url === '/v1/complete') {
    let body = '';
    var promptHeader;
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      body = JSON.parse(body);
      promptHeader = body.prompt;
      const uuid = uuidv4().toString();
      const options = {
        hostname: 'claude.ai',
        port: 443,
        path: `/api/organizations/${orgid}/chat_conversations`,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
          'User-Agent': ua
        }
      };

      const postData = JSON.stringify({
        "uuid": uuid,
        "name": ""
      });

      const req2 = https.request(options, (res2) => {
        res2.on('data', (d) => {
          process.stdout.write(d);
        });
      });

      req2.on('error', (error) => {
        console.error(error);
      });

      req2.write(postData);
      req2.end();
      const options2 = {
        hostname: 'claude.ai',
        port: 443,
        path: `/api/append_message`,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
          'User-Agent': ua
        }
      };

      const postData2 = JSON.stringify({
        "completion": {
          "prompt": promptHeader,
          "timezone": "",
          "model": body.model.replace(/v/g, '')
        },
        "organization_uuid": orgid,
        "conversation_uuid": uuid,
        "text": promptHeader,
        "attachments": []
      });
      const req3 = https.request(options2, (res3) => {
        let output = '';
        res3.on('data', (d) => {
          output = d
        });
        res3.on('end', () => {
          res.end(output);
        });
      });
      req3.on('error', (error) => {
        console.error(error);
      });

      req3.write(postData2);
      req3.end();
      
    });

  }

});
server.listen(5004, '127.0.0.1', () => {
  console.log(`\n\nSlaude2 running on: http://127.0.0.1:5004/v1\n`);
});
