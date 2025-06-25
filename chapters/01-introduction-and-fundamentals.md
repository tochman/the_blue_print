# Introduction and fundamentals

The Blue Print - Alpha Edition

ISBN: ---

Library of Congress Control Number: ---

Copyright (C) 2025 Thomas Ochman

All rights reserved. No part of this book may be reproduced or used in any manner without the prior written permission of the copyright owner, except for the use of brief quotations in a book review.

To request permissions, contact the author at thomas@agileventures.org

# Rationale

_React gets plenty of attention in programming resources, but most books and tutorials focus on the happy path. You'll find countless introductions to JSX and state management, but when it comes to building maintainable React applications that scale, the guidance gets thin fast._

_This book focuses entirely on that gap. Real React architecture patterns, practical strategies for handling complex state, and techniques that work when you're dealing with production applications instead of todo list examples.
I wrote this because I couldn't find a comprehensive resource that treated React as a serious discipline rather than a collection of scattered tutorials. Most books cover the basics, then jump to advanced topics without bridging the gap. This one stays put and goes deep._

_For developers who need to build React applications that last and teams who want to establish solid development practices, you'll find strategies that work in production environments, not just demos._

_This book assumes you're smart enough to take what works and leave what doesn't. Read it cover to cover or jump to the chapters that solve your immediate problems. Your choice._

\hfill Thomas

\hfill Gothenburg, June 2025

# Preface

Welcome to "The Blue Print: A Journey Into Web Application Development with React". This comprehensive guide equips you with the knowledge and skills needed to create scalable, maintainable React applications using modern development practices.

Each chapter builds on the previous ones, providing you with a complete education in modern React-from fundamentals to advanced topics like performance optimization, testing strategies, state management patterns, and production deployment.

::: tip
**About Chapter 5**

Fair warning: Chapter 5 (Advanced Patterns) is the most challenging section of this book. It covers sophisticated React patterns that are essential for building complex applications, but the concepts are dense and the code examples are substantial. Don't feel pressure to absorb everything at once-these are patterns you'll grow into as your React experience deepens.

Consider reading Chapter 5 through once for exposure to the concepts, then returning to implement specific patterns as your projects require them. The advanced patterns covered there represent the difference between good React developers and great ones, but they're tools you'll appreciate more as you encounter the problems they solve.
:::

Happy coding!

\hfill Thomas

::: tip
**Why read this book?**

This book offers:

- A systematic approach to learning React from fundamentals to production-ready applications
- Real-world examples and practical patterns to solve common development challenges
- Solutions to scaling and architecture problems in modern React applications
- Strategies for integrating React into your development workflow effectively

:::

# The blueprint approach

## Setting the stage

In building React applications, there's a simple truth: _good architecture is invisible_. When your React application is well-structured, components feel natural, state flows predictably, and new features integrate seamlessly. Conversely, poor architecture makes itself known through difficult debugging sessions, unpredictable behavior, and the dreaded "works on my machine" syndrome.

Most developers come to React with existing web development experience, but React requires a fundamental shift in thinking. The transition from imperative DOM manipulation to declarative component composition represents one of the most challenging-and rewarding-conceptual leaps in modern web development.

::: important
**The learning curve is normal**

React introduces several concepts that may feel foreign at first: JSX syntax, component lifecycle, unidirectional data flow, and the virtual DOM. The boundary between React-specific patterns and regular JavaScript can initially feel blurry. This confusion is normal and temporary-by the end of this book, these concepts will feel natural.
:::

React's ecosystem includes a rich vocabulary of terms: components, props, state, hooks, context, reducers, and more. You'll encounter functional components, class components, higher-order components, render props, and custom hooks. Rather than overwhelming you with definitions upfront, we'll introduce these concepts gradually as they become relevant to your understanding.

This book takes a practical approach: we'll explore concepts through concrete examples and build your understanding incrementally. Each chapter assumes you're intelligent enough to adapt the patterns to your specific context while providing clear guidance on proven approaches.

## The paradigm shift: imperative to declarative

Before we dive into React's technical bits, I need to talk to you about something that trips up almost every developer when they first start with React. It's not JSX syntax or component props-it's a fundamental shift in how you think about building user interfaces.

Most of us come to React from a world where we tell the browser exactly what to do, step by step. "Get this element, change its text, add a class, remove another element, show this thing, hide that thing." It's very procedural, very explicit, and honestly, it feels natural because that's how we think about most tasks in life.

React asks you to flip that on its head. Instead of saying "here's how to change the interface," React wants you to say "here's what the interface should look like right now." It's like the difference between giving someone turn-by-turn directions versus just showing them the destination on a map and letting GPS figure out the route.

### How we traditionally think about interfaces {.unnumbered .unlisted}

Let me give you a concrete example. Say you're building a simple counter. In traditional JavaScript, you might write something like this:

```javascript
// Traditional imperative approach
function incrementCounter() {
  const counter = document.getElementById('counter');
  const currentValue = parseInt(counter.textContent);
  counter.textContent = currentValue + 1;
  
  if (currentValue + 1 > 10) {
    counter.classList.add('warning');
  }
}
```

This is imperative programming-you're giving step-by-step instructions for what needs to happen.

### React's declarative approach {.unnumbered .unlisted}

React flips this completely. Instead of telling the browser how to update things, you describe what the end result should look like. Here's the same counter in React:

```jsx
// React's declarative approach
function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div className={count > 10 ? 'warning' : ''}>
      {count}
      <button onClick={() => setCount(count + 1)}>+</button>
    </div>
  );
}
```

See the difference? I'm not saying "when someone clicks, find the element, get its current value, add one, then check if it's over 10." Instead, I'm saying "this is what the counter should look like for any given count value."

::: tip
**Think in snapshots, not steps**

This is the mental shift that took me way too long to make: stop thinking about how to transform your interface from one state to another. Instead, think about what your interface should look like for each possible state. React handles all the messy transformation work for you.
:::

When I first encountered this pattern, I thought it was unnecessarily complicated. "Why can't I just change the thing I want to change?" But once it clicks-and it will click-you'll realize this approach is actually much simpler for complex interfaces.

### Why this matters {.unnumbered .unlisted}

I know this might seem like academic nonsense at first-"just tell me how to build the thing!" But trust me, this declarative approach pays huge dividends as your applications grow. Here's why:

**Your code becomes predictable**: When you describe what your interface should look like rather than how to change it, debugging becomes so much easier. You can look at your component and immediately understand what it will render for any given state.

**Maintenance gets easier**: Six months from now, when you need to modify that component, you won't have to trace through a complex sequence of DOM manipulations. You'll just look at the declarative description and know exactly what's happening.

**Bugs become obvious**: When something's wrong, you can focus on "what should this show?" rather than trying to debug a chain of transformations that might have gone wrong anywhere.

**Reusability happens naturally**: Declarative components are inherently more reusable because they focus on the relationship between data and display rather than specific implementation details.

I'll be honest-this shift doesn't happen overnight. For the first few weeks with React, you might find yourself fighting against the declarative approach, trying to imperatively manipulate things. That's completely normal. But stick with it, because once this pattern clicks, you'll wonder how you ever built complex interfaces any other way.

## React: origins and context

Let me give you some context about where React came from, because understanding its origins will help you understand why it works the way it does. React wasn't born in a vacuum-it was Facebook's answer to some very real, very painful problems they were facing with their user interfaces.

### Why React was created {.unnumbered .unlisted}

Picture this: it's 2011, and Facebook's interface is getting more complex by the day. Users are posting, commenting, liking, sharing, messaging-and all of these actions need to update multiple parts of the interface simultaneously. The old approach of manually manipulating the DOM for each change was becoming a nightmare.

I remember reading about the specific problem that sparked React's creation: the notification counter. You know, that little red badge that shows you have new messages? It seemed simple enough, but in a complex application, that counter might need to update when you receive a message, read a message, delete a message, or when someone comments on your post. Keeping track of all the places that counter needed to update, and making sure they all stayed in sync, was driving the Facebook engineers crazy.

React emerged as their solution to this chaos. Instead of manually tracking every possible update, what if the interface could just automatically reflect the current state of the data? What if you could describe what the interface should look like, and React would figure out what needed to change?

::: important
**React solved real problems**

React wasn't created by academics in an ivory tower-it was born from the frustration of trying to build complex, interactive interfaces with traditional DOM manipulation. Every React pattern and principle exists because it solved a real problem that developers were actually facing.
:::

The core problems React aimed to solve were:

**Coordination chaos**: When multiple parts of an interface needed to update in response to one change, keeping everything in sync manually was error-prone and exhausting.

**Performance bottlenecks**: Frequent DOM manipulations were slow, and optimizing them manually required way too much effort and expertise.

**Code complexity**: As applications grew, the imperative code required to manage interface updates became an unmaintainable mess.

**Reusability struggles**: Creating truly reusable interface components with traditional approaches was like trying to build LEGO sets that only worked in one specific configuration.

### Library vs. framework: understanding the distinction {.unnumbered .unlisted}

React is often called a "library" rather than a "framework," and this distinction matters for how you approach building applications with it.

::: tip
**React as a library**

React focuses specifically on building user interfaces and managing component state. Unlike frameworks that provide opinions about routing, data fetching, project structure, and build tools, React leaves these decisions to you and the broader ecosystem.
:::

**What this means in practice**:

- React provides the core tools for building components and managing their behavior
- You choose your own routing solution (React Router, Next.js routing, etc.)
- You decide how to handle data fetching (fetch API, Axios, React Query, etc.)
- You select your preferred styling approach (CSS modules, styled-components, Tailwind, etc.)
- You configure your own build tools (Vite, Create React App, custom Webpack, etc.)

This library approach offers both advantages and challenges:

**Advantages**: Flexibility to choose the best tools for your specific needs, smaller bundle sizes by including only what you use, and easier integration into existing projects.

**Challenges**: More decisions to make, potential for analysis paralysis when choosing tools, and need to understand how different pieces work together.

### React in the component-based ecosystem {.unnumbered .unlisted}

React popularized component-based architecture for web applications, but it's part of a broader movement toward this approach. Understanding React's place in this ecosystem helps contextualize its patterns and principles.

**Other component-based libraries and frameworks**:

- **Vue.js**: Offers a more framework-like experience with built-in routing and state management options
- **Angular**: A full framework with strong opinions about application structure
- **Svelte**: Compiles components to optimized vanilla JavaScript
- **Web Components**: Browser-native component standards

React's influence on this ecosystem has been significant. Many patterns that originated in React have been adopted by other libraries, and React itself has evolved by incorporating ideas from the broader community.

::: note
**Why this context matters**

Understanding that React is one approach among many helps you make informed decisions about when to use it and how to combine it with other tools. The patterns we'll explore in this book aren't React-specific-many translate to other component-based approaches.
:::

## The thinking framework

Before we dive into the technical details, it's worth establishing the mental framework that will guide our approach throughout this book. Building with React isn't just about learning syntax and APIs-it's about developing a way of thinking that leads to maintainable, scalable applications.

::: important
**A note on "best practices"**

Throughout this book, you'll encounter various approaches and patterns often called "best practices." It's important to understand that React itself is deliberately unopinionated-it provides tools but doesn't dictate how to use them. What works best depends heavily on your specific context: team size, project requirements, timeline, and experience level. We'll explore this concept in depth in Chapter 2.
:::

::: important
**Architecture first, implementation second**

The most successful React applications start with thoughtful planning, not rushed coding. Taking time to think through component relationships, data flow, and user interactions before writing code will save countless hours of refactoring later.

:::

At its core, effective React applications revolve around several key principles that we'll explore throughout this book:

**Visual planning**: Before writing a single line of code, successful React developers map out their component hierarchy and data flow. This connects directly to declarative thinking-instead of planning _how_ to build features step by step, you plan _what_ your interface should look like and let React handle the implementation details.

**Data flow strategy**: Understanding where data lives and how it moves through your application is crucial. React's unidirectional data flow isn't just a technical constraint-it's a design philosophy that makes applications predictable and debuggable.

**Component boundaries**: Learning to identify the right boundaries for your components is perhaps the most important skill when building React applications. Components that are too small become unwieldy, while components that are too large become unmaintainable.

**Composition over inheritance**: React favors composition patterns that allow you to build complex UIs from simple, reusable pieces. This approach leads to more flexible and maintainable code than traditional inheritance-based architectures.

**Progressive complexity**: Starting simple and adding complexity gradually is not just a learning strategy-it's a development strategy. Even experienced developers benefit from building applications incrementally, validating each layer before adding the next.

These principles will resurface throughout our journey, each time with deeper exploration and practical examples. In Chapter 2, we'll put these concepts into practice with hands-on exercises in component design and architecture planning.

## A journey in 10 acts

::: setup

**Book structure**

1. **Introduction and fundamentals** - Core React concepts and development philosophy
2. **Component thinking** - Breaking down UIs into reusable, composable pieces
3. **State and props** - Managing data flow and component communication
4. **Hooks and lifecycle** - Modern React patterns and component behavior
5. **Advanced patterns** - Higher-order components, render props, and composition
6. **Performance optimization** - Making React applications fast and efficient
7. **Testing React components** - Ensuring reliability through comprehensive testing
8. **State management** - Handling complex application state with various tools
9. **Production deployment** - Taking React applications from development to production
10. **The journey continues** - Future directions and continuous learning in React

:::

We'll embark on a journey to enhance your React skills and empower you to build more maintainable, scalable web applications. React is a broad topic, and teaching someone new to it presents challenges. It's difficult to discuss one aspect of React without touching on others that might still be beyond your current skillset.

I believe in structure and that practice makes perfect. There's only one way to learn to write good React applications-by building them yourself, not just reading about them or watching tutorials. For this reason, I've divided this book into chapters that guide you through various aspects of React step-by-step, with each chapter containing examples and exercises I strongly encourage you to complete.

First, we'll explore React's core concepts and their benefits during development. This section contains theory and patterns that need clarification. Though potentially challenging, understanding this foundation is crucial. The React ecosystem is full of specific terminology that often carries different meanings depending on context. I'll do my best to clarify ambiguities and establish a consistent framework for this book.

As we focus on building user interfaces and managing application state, you'll learn the capabilities and limitations of React. With this foundation, we'll dive into the practical aspects of structuring and building React applications for various scenarios. We'll start with simple components with limited complexity, gradually increasing difficulty to tackle more complex applications and architectural challenges.

Along the way, we'll cover a wide range of topics. Chapter 2, "Component Thinking," introduces the fundamental mindset shift required for effective React applications. Building on the imperative-to-declarative paradigm shift introduced in this chapter, you'll see concrete examples of how this thinking applies to real interface problems and learn to break down complex user interfaces into small, reusable components that work together harmoniously.

Chapter 3, "State and Props," dives deep into React's data flow patterns. We'll explore how to manage component state effectively, establish clear communication patterns between components through props and callbacks, and handle data fetching and network requests in React applications.

In Chapter 4, "Hooks and Lifecycle," you'll master modern React patterns through hooks while understanding component lifecycle concepts. Through guided exercises, you'll learn to handle side effects, manage complex state, optimize component behavior using React's powerful hooks system, and integrate API calls seamlessly into component lifecycles.

Chapter 5, "Advanced Patterns," takes your skills to the next level with sophisticated techniques for building flexible, reusable components. We'll cover higher-order components, render props, compound components, and composition patterns that enable you to build truly scalable React applications.

Chapter 6, "Performance Optimization," addresses the challenges of building fast, responsive React applications. You'll learn to identify performance bottlenecks, implement effective optimization strategies, and ensure your applications remain snappy as they grow in complexity.

Chapter 7, "Testing React Components," focuses on building confidence in your React applications through comprehensive testing strategies. We'll cover unit testing, integration testing, and end-to-end testing approaches that ensure your components work correctly in isolation and as part of larger systems.

Chapter 8, "State Management," explores solutions for handling complex application state that goes beyond what React's built-in state can handle effectively. We'll examine various state management libraries and patterns, helping you choose the right approach for your specific needs.

Chapter 9, "Production Deployment," covers the essential steps for taking your React applications from development to production environments. We'll discuss build optimization, deployment strategies, monitoring, and maintenance practices that ensure your applications run reliably for users.

Finally, we'll conclude our journey in Chapter 10, "The Journey Continues." While our time together ends here, your journey with React continues. We'll reflect on the knowledge you've gained and discuss the future of React, offering guidance on expanding your expertise in this rapidly evolving ecosystem.

## A word of caution {.unnumbered .unlisted}

::: caution
**Different approaches to building React applications**

The React community is diverse, with many valid approaches to building applications. While this book presents patterns that have proven successful in my experience, they are not the only valid approaches. Take what works for you, adapt techniques to your context, and remember that the ultimate goal is creating applications that deliver value to users.
:::

It's important to acknowledge that building React applications is a diverse field where professionals employ varied strategies and architectural patterns. Some approaches may align with mine, while others diverge significantly. These variations are natural, as each person and team brings unique experiences, constraints, and requirements.

This book offers a structured approach to a complex topic, allowing you to build on existing knowledge and discover techniques that work for your specific context. However, I emphasize that the perspectives shared here aren't derived from scientific expertise or universal truth, but from my personal experiences and knowledge gained across various React projects and teams. My approach has consistently led to increased developer productivity, better code maintainability, improved team collaboration, and more successful project outcomes.

Remember that every developer's journey is unique. While these strategies have succeeded for me and the teams I've worked with, it's essential to adapt them to your context, project requirements, and team dynamics. As you explore React, select the best elements from various approaches and incorporate them into your workflow in ways that benefit you and your users most.

The React ecosystem evolves rapidly, and what works today may be superseded by better approaches tomorrow. Stay curious, keep learning, and always be willing to reconsider your assumptions as new patterns and tools emerge.

# The Blueprint: Foundations

## The big picture

Before we dive into the nitty-gritty of React, let's take a step back and look at the big picture. Building web applications is a complex endeavor, and it's easy to get lost in the weeds of frameworks, libraries, and tools. But at the end of the day, you're building an application to solve a problem for your users. Keeping this goal in mind will help you make better decisions about how to build your application.

### The role of a web application

A web application is a tool that users interact with to accomplish a goal. Whether it's sending a message, making a purchase, or tracking a workout, your application is here to help users do something. This seems obvious, but it's important to remember because it should drive all the decisions you make during development.

### The components of a web application

At a high level, a web application consists of three components:

1. **The user interface (UI)**: What the user sees and interacts with
2. **The server**: Where your application logic runs and data is processed
3. **The database**: Where your application data is stored

These components communicate with each other to perform the actions that users request. For example, when a user submits a form, the UI sends the data to the server, which processes it and updates the database. The server then sends a response back to the UI, which updates to reflect the changes.

### How React fits in

React is a library for building user interfaces. It helps you create the UI component of your web application. But React is not a complete solution for building web applications. It doesn't include features for routing, data fetching, or state management. Instead, React focuses on providing a great developer experience for building UI components.

::: important
**React is not a framework**

It's important to understand that React is not a framework for building web applications. It's a library for building user interfaces. This distinction matters because it means that React doesn't dictate how you structure your application or how you manage data. You have the flexibility to choose the best tools and patterns for your specific needs.
:::

## JSX: The foundation of React's declarative power

Before we dive into React's history, let me introduce you to the syntax that makes React's declarative approach possible: JSX. When people first see JSX, they often have one of two reactions: "This looks familiar!" or "Wait, you're putting HTML in your JavaScript?" Both reactions are totally valid, and I want to address what JSX actually is and why it's so powerful.

### What is JSX? {.unnumbered .unlisted}

JSX stands for JavaScript XML, and it's a syntax extension that lets you write HTML-like code directly in your JavaScript. If you've worked with HTML or XML, JSX will look familiar, but it's actually much more powerful because it's JavaScript underneath.

::: example

```jsx
// This is JSX - looks like HTML, but it's actually JavaScript
function WelcomeMessage() {
  const userName = "Sarah";
  const timeOfDay = new Date().getHours() < 12 ? "morning" : "afternoon";
  
  return (
    <div className="welcome">
      <h1>Good {timeOfDay}, {userName}!</h1>
      <p>Welcome to your music practice dashboard.</p>
    </div>
  );
}
```

:::

Here's what's happening: that HTML-like syntax gets transformed by a build tool (like Babel) into regular JavaScript function calls. The JSX above actually becomes something like this:

```javascript
// What JSX becomes under the hood
function WelcomeMessage() {
  const userName = "Sarah";
  const timeOfDay = new Date().getHours() < 12 ? "morning" : "afternoon";
  
  return React.createElement(
    "div",
    { className: "welcome" },
    React.createElement("h1", null, "Good ", timeOfDay, ", ", userName, "!"),
    React.createElement("p", null, "Welcome to your music practice dashboard.")
  );
}
```

You could write React using only `React.createElement` calls, but JSX makes it so much more readable and maintainable. It's like the difference between writing assembly code and writing in a high-level programming language-technically equivalent, but one is much more human-friendly.

### JSX vs. HTML: Similar but different {.unnumbered .unlisted}

JSX looks like HTML, but there are some important differences that trip up newcomers:

**Attributes use camelCase**: HTML's `class` becomes `className`, `for` becomes `htmlFor`, and `onclick` becomes `onClick`.

**Everything must be closed**: Self-closing tags need the slash (`<br />`, `<input />`), and every opening tag needs a closing tag.

**JavaScript expressions go in curly braces**: Anything inside `{}` is evaluated as JavaScript, so you can use variables, function calls, and expressions.

**Components must return a single parent element**: You can't return multiple sibling elements without wrapping them (though React Fragments help with this).

::: tip
**TypeScript users: TSX**

If you're using TypeScript (which I highly recommend for larger projects), you'll use `.tsx` files instead of `.jsx`. The syntax is identical, but you get the added benefits of type checking and better IDE support.
:::

## Understanding components: React's building blocks

Now let's talk about what components actually are, because this is where React's true power becomes apparent. A React component is essentially a function that returns a piece of user interface. That's it. But this simple concept is incredibly powerful.

### Components as functions {.unnumbered .unlisted}

Think about regular JavaScript functions for a moment. They have a name, they can take arguments (parameters), they process data, and they return something. Components work exactly the same way:

- **Name**: Components have names (like `WelcomeMessage` or `UserProfile`)
- **Arguments**: Components receive "props" as their arguments
- **Process data**: Components can use state, perform calculations, make decisions
- **Return something**: Instead of returning data, components return JSX describing part of the UI

::: example

```jsx
// A simple component - it's just a function!
function PracticeTimer(props) {
  const { duration, isActive } = props;
  
  // Process data
  const minutes = Math.floor(duration / 60);
  const seconds = duration % 60;
  const displayTime = `${minutes}:${seconds.toString().padStart(2, '0')}`;
  
  // Return UI based on current state and props
  return (
    <div className={`timer ${isActive ? 'active' : 'paused'}`}>
      <h3>Practice Timer</h3>
      <div className="time-display">{displayTime}</div>
      <div className="status">
        {isActive ? '[Music] Recording...' : '[Pause] Paused'}
      </div>
    </div>
  );
}
```

:::

### Components are isolated and reusable {.unnumbered .unlisted}

Here's what makes components so powerful: they're isolated pieces of your user interface. Each component encapsulates its own logic, appearance, and behavior. This isolation means you can:

**Reuse them**: The same `PracticeTimer` component can be used in different parts of your app
**Test them independently**: You can test a component in isolation without worrying about the rest of your app
**Reason about them**: Each component has a clear responsibility and interface
**Compose them**: Complex interfaces are built by combining simple components

Think of components like LEGO blocks. Each block has a specific shape and purpose, but you can combine them in countless ways to build complex structures. The key is that each block (component) knows how to do its own job well.

### The component hierarchy {.unnumbered .unlisted}

React applications are built as a tree of components. You have a root component (usually called `App`) that renders other components, which can render other components, and so on. Data flows down this tree through props, and events bubble up through callback functions.

::: example

```jsx
// Component hierarchy example
function App() {
  return (
    <div className="app">
      <Header />
      <MainContent>
        <PracticeSession />
        <ProgressTracker />
      </MainContent>
      <Footer />
    </div>
  );
}

function MainContent({ children }) {
  return (
    <main className="main-content">
      {children}
    </main>
  );
}

function PracticeSession() {
  return (
    <div className="practice-session">
      <PracticeTimer duration={300} isActive={true} />
      <PieceSelector />
      <NotesEditor />
    </div>
  );
}
```

:::

## What React does for you

Now that you understand JSX and components, let's talk about what React actually handles behind the scenes. This is important because understanding what React takes care of helps you appreciate why it makes building complex user interfaces so much easier.

### The Virtual DOM: React's secret weapon {.unnumbered .unlisted}

When you write JSX and return it from components, you're not directly manipulating the browser's DOM. Instead, you're creating a virtual representation of what the DOM should look like. React takes this virtual representation and efficiently updates the actual DOM for you.

Here's why this matters: DOM manipulation is slow. Reading from the DOM is slow, writing to the DOM is slow, and doing it frequently can make your app feel sluggish. React solves this by:

1. **Creating a virtual DOM in memory** (which is fast)
2. **Comparing your new virtual DOM with the previous version** (called "diffing")
3. **Updating only the parts of the real DOM that actually changed** (called "reconciliation")

You describe what you want the interface to look like, and React figures out the most efficient way to make it happen.

### State management and re-rendering {.unnumbered .unlisted}

React also handles the complex task of keeping your interface in sync with your data. When state changes in a component, React:

1. **Schedules a re-render** of that component and its children
2. **Calls your component functions again** with the new state
3. **Generates a new virtual DOM tree**
4. **Efficiently updates the real DOM** to match

This happens automatically. You don't have to track which parts of the interface need to update when data changes-React figures it out for you.

### Event handling and browser differences {.unnumbered .unlisted}

React also abstracts away browser differences in event handling. When you write `onClick={handleClick}`, React gives you a consistent event object that works the same way across all browsers. No more worrying about `event.preventDefault()` vs `event.returnValue = false` or other browser-specific quirks.

### What React is (and isn't) {.unnumbered .unlisted}

So is React a framework or a library? The answer depends on how you look at it:

**React is a library** in that it focuses specifically on one thing: building user interfaces. It doesn't include routing, data fetching, or build tools. You choose those yourself.

**React feels like a framework** because it provides a complete paradigm for thinking about and building user interfaces. Once you adopt React's patterns, they influence how you structure your entire application.

**React's core responsibilities**:
- Component rendering and re-rendering
- State management within components
- Event handling and browser compatibility
- Virtual DOM and efficient DOM updates
- Development tools and error boundaries

**What React doesn't provide**:
- Routing (you add React Router or similar)
- Data fetching (you add Axios, React Query, or similar)
- Styling systems (you add CSS modules, styled-components, or similar)
- Build tools (you add Vite, Webpack, or similar)
- Testing utilities (you add Jest, React Testing Library, or similar)

This modular approach means you can choose the best tools for your specific needs, but it also means you have more decisions to make when setting up a project.

::: important
**React's philosophy**

React's core philosophy is to provide excellent tools for the component layer while letting you choose how to handle everything else. This makes React incredibly flexible but requires you to understand how different pieces of the ecosystem work together.
:::
