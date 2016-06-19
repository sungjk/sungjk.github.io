---
layout: post
title: OOP Interview Questions
categories: [general, computer science, cpp]
tags: [cpp, oop]
fullview: false
comments: true
---


### What is Object Oriented Programming?

Object Oriented Programming (OOP) is a programming paradigm where the complete software operates as a bunch of objects talking to each other. An object is a collection of data and methods that operate on its data.


### Why OOP?

The main advantage of OOP is better manageable code that covers following.
1) The overall understanding of the software is increased as the distance between the language spoken by developers and that spoken by users.
2) Object orientation eases maintenance by the use of encapsulation.   One can easily change the underlying representation by keeping the methods same.
OOP paradigm is mainly useful for relatively big software. See this for a complete example that shows advantages of OOP over procedural programing.


### What are main features of OOP?

Encapsulation
Polymorphism
Inheritance


### What is encapsulation?

Encapsulation is referred to one of the following two notions.
1) Data hiding: A language feature to restrict access to members of an object. For example, private and protected members in C++.
2) Bundling of data and methods together: Data and methods that operate on that data are bundled together.


### What is Polymorphism? How is it supported by C++?

Polymorphism means that some code or operations or objects behave differently in different contexts. In C++,  following features support polymorphism.
Compile Time Polymorphism: Compile time polymorphism means compiler knows which function should be called when a polymorphic call is made.  C++ supports compiler time polymorphism by supporting features like templates, function overloading and default arguments.
Run Time Polymorphism: Run time polymorphism is supported by virtual functions. The idea is, virtual functions are called according to the type of object pointed or referred, not according to the type of pointer or reference. In other words, virtual functions are resolved late, at runtime.

    class Animal
    {
    public:
        virtual void Cry() {}
    };

    class Dog : public Animal
    {
    public:
        virtual void Cry() {}
    };

    template<typename T> void foo(T a)
    {
        a.Cry();    // Compile Time Polymorphism.
    }

    void foo(Animal \*p)
    {
        p->Cry();   // Run Time Polymorphism.
    }


### What is Inheritance? What is the purpose?

The idea of inheritance is simple, a class is based on another class and uses data and implementation of the other class.
The purpose of inheritance is Code Reuse.


### What is Abstraction?

The first thing with which one is confronted when writing programs is the problem. Typically we are confronted with “real-life” problems and we want to make life easier by providing a program for the problem. However, real-life problems are nebulous and the first thing we have to do is to try to understand the problem to separate necessary from unnecessary details: We try to obtain our own abstract view, or model, of the problem.



#### References:

http://gd.tuwien.ac.at/languages/c/c++oop-pmueller/tutorial.html
