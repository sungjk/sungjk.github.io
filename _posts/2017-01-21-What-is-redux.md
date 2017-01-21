---
layout: entry
title: What is Redux?
author: 김성중
author-email: ajax0615@gmail.com
description: This post is simple description about redux.
publish: true
---

## What is difference with React?
**Redux** is the *data* contained inside this application box whereas react is really the *views* contained inside the application box when redux describes itself as a state container.

## Simple example
It really means a collection of all the data that describes the app that not only includes the hard data like the list of books but it also includes more mental level properties like what is the currently selected book. On the other hand React represents the views which translates the app’s data into something that can be displayed on the screen as something that the user can actually interact with.

![book_diagram](/images/2017/01/21/book_diagram.png "book_diagram"){: .center-image }

## What is difference with Flux?
Now you might thinking OK well, you know this doesn’t really look that much different from angular, backbone or even flux right. What’s the difference here? The difference here is that we centralize all of the applications data inside of a **single object**. When you have any other javascript library you always have separate collections of data on you know backbone has collections, flux says different stores, Angular has whatever.

## Review
Remember redux contains the state of the application or the data that tells our components how or what they should render.
