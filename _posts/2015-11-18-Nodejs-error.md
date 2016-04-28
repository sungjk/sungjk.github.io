---
layout: post
title: listen EADDRINUSE 에러 발생
categories: [general, setup, demo]
tags: [demo, dbyll, dbtek, setup]
fullview: false
comments: true
---

Node.js 개발 도중 `Error: listen EADDRINUSE` 에러가 발생한다면 현재 동일한 포트를 사용 중 프로세서가 있기 때문입니다.

따라서, 아래 명령어를 통해 해당 프로세서를 kill 시켜야 합니다.

`kill $(ps ax | grep '[j]s' | awk '{ print $1 }')`
