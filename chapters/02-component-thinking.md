# Component thinking

Remember that mental shift I talked about in Chapter 1? The move from imperative to declarative thinking? Well, now we're going to see it in action. This is where React starts to feel different from any JavaScript you've written before, and honestly, this is where a lot of developers either fall in love with React or get really frustrated with it.

I want to be upfront with you: this chapter is going to change how you think about building user interfaces. We're not just learning new syntax or API calls-we're developing a completely different approach to organizing and structuring interactive applications. It's the difference between thinking like a micromanager who controls every detail and thinking like an architect who designs systems that work elegantly on their own.

The good news? Once you get this mindset, building complex interfaces becomes way more enjoyable. The not-so-good news? It might feel uncomfortable at first if you're used to having direct control over every DOM element and every interaction.

::: tip
**What you'll learn in this chapter**

- How to stop thinking in terms of "find this element and change it" and start thinking in terms of "what should this look like?"
- The art of breaking down complex interfaces into logical, reusable pieces
- How to design data flow so your components actually make sense together
- Why good component boundaries can save your sanity (and your project)
- A systematic way to plan your React architecture before you write a single line of JSX
:::

## From DOM manipulation to component composition

Let me show you what I mean with a real example. Most of us come to React from a world where building interactive UIs meant a lot of `getElementById`, `addEventListener`, and manually updating element properties. It's very hands-on, very explicit, and it gives you the illusion of total control.

But here's the thing-that control comes at a massive cost when your application grows beyond a few simple interactions.

::: important
**Key concept: Imperative vs Declarative programming**

**Imperative programming** describes _how_ to accomplish a task step by step. You write explicit instructions: "First do this, then do that, then check this condition, then do something else."

**Declarative programming** describes _what_ you want to achieve, letting the framework handle the _how_. You describe the desired end state and let React figure out how to get there.
:::

### Understanding the mental shift {.unnumbered .unlisted}

Let me give you a concrete example that illustrates this shift. Say you're building a simple modal dialog-you know, one of those popup windows that appears over your main content.

In traditional JavaScript, your brain thinks like this: "When someone clicks the open button, I need to find the modal element, add a class to make it visible, probably add an overlay, maybe animate it in, add an event listener to close it when they click outside..." You're thinking in terms of a sequence of actions.

::: important
**The old way: imperative thinking**

```javascript
// Traditional imperative approach - lots of manual steps
function openModal() {
  const modal = document.getElementById('modal');
  const overlay = document.getElementById('overlay');
  
  modal.style.display = 'block';
  overlay.style.display = 'block';
  modal.classList.add('modal-open');
  
  // Add event listeners
  overlay.addEventListener('click', closeModal);
  document.addEventListener('keydown', handleEscape);
  
  // Prevent body scroll
  document.body.style.overflow = 'hidden';
}

function closeModal() {
  // Reverse all the steps above...
  const modal = document.getElementById('modal');
  const overlay = document.getElementById('overlay');
  
  modal.classList.remove('modal-open');
  modal.style.display = 'none';
  overlay.style.display = 'none';
  
  // Clean up event listeners
  overlay.removeEventListener('click', closeModal);
  document.removeEventListener('keydown', handleEscape);
  
  // Restore body scroll
  document.body.style.overflow = '';
}
```
:::

Look at all those steps! And that's just for a simple modal. Imagine if you have multiple modals, or nested modals, or modals with different behaviors. The complexity explodes quickly.

React asks you to think differently:

::: example

```javascript
// Imperative approach - describing HOW to change the interface
function showModal() {
  document.getElementById("modal").style.display = "block";
  document.getElementById("overlay").classList.add("active");
  document.body.classList.add("no-scroll");
}

function hideModal() {
  document.getElementById("modal").style.display = "none";
  document.getElementById("overlay").classList.remove("active");
  document.body.classList.remove("no-scroll");
}

// Usage requires manual state tracking
let modalIsOpen = false;
button.addEventListener('click', () => {
  if (modalIsOpen) {
    hideModal();
    modalIsOpen = false;
  } else {
    showModal();
    modalIsOpen = true;
  }
});
```

:::

Notice how the imperative approach requires you to manually track the current state (`modalIsOpen`), write explicit functions for each transformation, remember to update all related elements (modal, overlay, body), and handle the state tracking logic separately from the UI updates.

::: important
**The React way: declarative thinking**

```jsx
// React's approach - describe WHAT it should look like
function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className={`app ${isModalOpen ? "no-scroll" : ""}`}>
      <button onClick={() => setIsModalOpen(!isModalOpen)}>
        {isModalOpen ? "Close Modal" : "Open Modal"}
      </button>
      
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
      {isModalOpen && <Overlay onClick={() => setIsModalOpen(false)} />}
    </div>
  );
}

function Modal({ isOpen, onClose }) {
  if (!isOpen) return null;
  
  return (
    <div className="modal">
      <div className="modal-content">
        <h2>Modal Title</h2>
        <p>Modal content goes here...</p>
        <button onClick={onClose}>Close</button>
      </div>
    </div>
  );
}
```
:::

See the difference? In the React version, I'm not telling the browser how to open the modal step by step. Instead, I'm saying "here's what the UI should look like when the modal is open, and here's what it should look like when it's closed." React figures out all the DOM manipulation details.

This felt really weird to me at first. My initial reaction was "but I want control over exactly how things happen!" But here's what I discovered: you don't actually want that control. What you want is predictable, maintainable code. And the declarative approach gives you that in spades.

::: tip
**Why this matters**

Once you start building anything more complex than a simple modal, the imperative approach becomes a nightmare to manage. You end up with state scattered everywhere, complex interdependencies, and bugs that are incredibly hard to track down. The declarative approach scales beautifully because each component just describes what it should look like, period.
:::

### The compounding benefits {.unnumbered .unlisted}

I know this mental shift feels strange if you're used to having direct control over the DOM. But stick with me here, because the benefits compound quickly:

**Your code becomes predictable**: When you can look at a component and immediately understand what it will render for any given state, debugging becomes so much easier.

**Testing gets simpler**: Instead of simulating complex user interactions and DOM manipulations, you just pass props to a component and verify what it renders.

**Reusability happens naturally**: When components describe their appearance based on props, they automatically become more flexible and reusable.

**Bugs become obvious**: Most React bugs happen because your state doesn't match what you think it should be. With declarative components, the relationship between state and UI is explicit and easy to trace.

I remember the moment this clicked for me. I was building a complex form with conditional fields, validation states, and dynamic sections. In traditional JavaScript, it would have been a mess of event handlers and DOM manipulation. But with React's declarative approach, each part of the form just described what it should look like based on the current data. It was like magic.

## Understanding "best practices" and architectural patterns

Before we dive deeper into React patterns, I need to have a slightly awkward conversation with you about "best practices." This is important because you're going to encounter a lot of conflicting advice as you learn React, and I want to give you some context for navigating that.

Here's the thing: React is deliberately unopinionated. The React team gives you powerful tools but doesn't tell you exactly how to use them. This is actually a strength-it means React can adapt to lots of different use cases-but it also means there's no official "React way" to structure your applications.

### The moving target of "best practices" {.unnumbered .unlisted}

I've been working with React for years, and I've watched "best practices" evolve dramatically. Class components were the standard, then functional components took over. Higher-order components were everywhere, then render props became popular, then custom hooks made both of them less necessary. Redux was the default state management solution, now Context API and simpler libraries are often preferred.

This isn't a bug in the React ecosystem-it's a feature. The community learns, experiments, and discovers better patterns over time. But it can be overwhelming when you're trying to learn the "right" way to do things.

::: important
**The reality of React patterns**

What you'll read online as "best practices" are really just "patterns that have worked well for many developers in many situations." They're proven approaches, but they're not laws of physics. Your specific situation might call for a different approach, and that's perfectly fine.
:::

### Focus on principles, not just patterns {.unnumbered .unlisted}

Here's what I've learned after years of watching React patterns come and go: the specific patterns change, but the underlying principles stay remarkably consistent.

**Patterns** are specific solutions-like "use custom hooks for stateful logic" or "separate container and presentation components." These are valuable, but they evolve.

**Principles** are the deeper guidelines-like "each component should have a single responsibility" or "keep your data flow predictable." These tend to remain valuable regardless of which specific patterns you use.

When I teach React architecture, I focus more on helping people understand *why* certain patterns work rather than just *how* to implement them. Because once you understand the principles, you can evaluate new patterns as they emerge and make good decisions about whether they're right for your situation.

### Context matters: choosing the right approach {.unnumbered .unlisted}

Your architectural choices should be influenced by your specific context:

**Working alone vs. team development**: Solo projects allow for more personal preferences and rapid iteration, while team projects require consistent conventions and clear communication patterns. Team size affects how much abstraction and documentation you need.

**Project timeline and scope**: Prototypes and MVPs should prioritize speed and flexibility over perfect architecture. Long-term applications benefit from investing in maintainability, testing, and clear patterns. Short-term projects often work better with simpler approaches than complex architectures.

**Team experience level**: Beginner teams benefit from well-established patterns and conventions. Experienced teams can handle more sophisticated architectures and custom solutions. Mixed experience teams need clear documentation and consistent patterns.

**Application complexity**: Simple applications shouldn't be over-engineered with complex state management. Complex applications benefit from investing in proper architecture and tooling. Growing applications should plan for scalability but avoid premature optimization.

::: example
**Context-driven decisions in practice**

**Scenario 1: Solo developer, 2-week prototype**
- Use simple local state and prop drilling
- Minimal abstraction, focus on functionality
- Direct API calls in components are fine

**Scenario 2: 5-person team, 2-year product**
- Establish clear component patterns and naming conventions
- Implement proper separation between data fetching and presentation
- Use consistent error handling and loading states
- Document architectural decisions

**Scenario 3: Large team, enterprise application**
- Implement strict component patterns and code organization
- Use TypeScript for better collaboration and maintainability
- Establish testing standards and CI/CD processes
- Create reusable component libraries
:::

### What this book provides {.unnumbered .unlisted}

The approaches presented in this book represent **one effective way** to structure React applications-approaches that have proven successful in various professional contexts. They're not the only way, and they may not be the best way for your specific situation.

::: caution
**Take what works, leave what doesn't**

As you read through the patterns and techniques in this book, consider them through the lens of your own context. Some practices might be perfect for your situation, others might be overkill, and some might not fit your constraints at all. The goal is to build your understanding so you can make informed decisions about what works for you.
:::

**Our focus**: We emphasize approaches that tend to work well for teams building applications that need to be maintained over time, developers who want clear and predictable patterns, applications that are expected to grow in complexity, and contexts where code quality and maintainability matter.

If you're building a quick prototype or working in a very different context, you might choose different approaches-and that's perfectly valid.

### Building your judgment {.unnumbered .unlisted}

The real skill when building React applications isn't memorizing the "right" patterns-it's developing the judgment to choose appropriate solutions for your context. This comes from understanding the principles behind different approaches, experiencing the consequences of different architectural decisions, learning from the community while forming your own opinions, and staying curious about new approaches without chasing every trend.

As we explore the techniques in this book, we'll try to explain not just *what* to do, but *why* these approaches work and *when* you might choose alternatives.

## The architecture-first mindset

Effective React applications begin not with code, but with thoughtful planning. Before writing any component code, experienced developers engage in what we call "architectural thinking"-the practice of mapping out component relationships, data flow, and interaction patterns before implementation begins.

::: important
**Definition: Architectural thinking**

Architectural thinking is the deliberate practice of designing your application's structure before writing code. It involves:

- **Component planning**: Identifying what components you need and how they relate to each other
- **Data flow design**: Determining where state lives and how information moves through your application  
- **Responsibility mapping**: Deciding which components handle which concerns
- **Integration strategy**: Planning how different parts of your application will work together

This upfront planning ensures scalability, maintainability, and clear separation of concerns.
:::

Many developers skip this planning phase and jump straight into coding, which often leads to components that are too large and try to do too much, confusing data flow patterns that are hard to debug, tight coupling between components that should be independent, and difficulty adding new features without breaking existing functionality.

### Why architecture-first matters {.unnumbered .unlisted}

The architecture-first approach provides several critical advantages:

**Prevents refactoring cycles**: Good upfront planning eliminates the need for major structural changes later when requirements become clearer.

**Reveals complexity early**: Planning exposes potential problems when they're cheap to fix, not after you've written thousands of lines of code.

**Enables team collaboration**: Clear architectural plans help team members understand how pieces fit together and where to make changes.

**Improves code quality**: When you know where each piece of functionality belongs, you write more focused, single-purpose components.

### Visual planning exercises {.unnumbered .unlisted}

The most effective way to develop architectural thinking is through visual planning. Take a whiteboard, paper, or digital tool and practice breaking down interfaces into components.

::: tip
**Recommended tools for visual planning**

- **Physical tools**: Whiteboard, paper and pencil, sticky notes
- **Digital tools**: Figma, Sketch, draw.io, Miro, or even simple drawing apps
- **The key**: Use whatever feels natural and allows quick iteration
:::

::: example
**Exercise: component identification**

Visit a popular website (like GitHub, Twitter, or Medium) and practice identifying potential React components. Draw boxes around distinct pieces of functionality and consider:

- What data does each component need?
- How do components communicate with each other?
- Which components could be reused in other parts of the application?
- Where should state live for each piece of data?

**Example walkthrough**: Looking at a Twitter-like interface, you might identify:
- `Header` component (logo, navigation, user menu)
- `TweetComposer` component (text area, character count, post button)
- `Feed` component (container for tweet list)
- `Tweet` component (avatar, content, actions, timestamp)
- `Sidebar` component (trends, suggestions, ads)

Each component has clear boundaries and responsibilities, making the overall application easier to understand and maintain.

:::

### The component hierarchy principle {.unnumbered .unlisted}

Every React application is a tree of components, and understanding this hierarchy is crucial for effective architecture. When planning your component structure, consider these guidelines:

::: note
**Definition: Component hierarchy**

The component hierarchy is the tree-like structure that describes how components are nested within each other. Just like HTML elements form a DOM tree, React components form a component tree where parent components contain and manage child components.
:::

**Single responsibility principle**: Each component should have one clear purpose. If you find yourself struggling to name a component or describing its purpose requires multiple sentences, it likely needs to be broken down further.

::: example
**Good component responsibilities**:
- `UserCard` - displays user information
- `SearchBar` - handles search input and triggers search
- `ProductList` - renders a list of products
- `ShoppingCart` - manages cart items and checkout

**Poor component responsibilities**:
- `UserDashboard` - displays user info, handles search, shows products, manages cart, and processes checkout (too many responsibilities)
:::

**Data ownership**: Components should own the data they need to function. When data needs to be shared between components, it should live in their closest common ancestor.

::: tip
**The principle of data ownership**

Data should live in the component that:
1. Needs to modify that data, OR
2. Is the closest common ancestor of all components that need that data

This principle helps prevent prop drilling (passing props through many levels) and keeps your data flow predictable.
:::

**Reusability consideration**: While not every component needs to be reusable, thinking about reusability during design often leads to better component boundaries and cleaner interfaces.

### Common hierarchy patterns {.unnumbered .unlisted}

Successful React applications often follow similar hierarchical patterns:

**Container/Presentation pattern**: Separate components that manage data (containers) from components that display data (presentational).

**Feature-based grouping**: Group related components together that work toward the same user goal.

**Composition over inheritance**: Build complex components by combining simpler ones rather than extending base classes.

## Component boundaries and responsibilities

Identifying the right boundaries for your components is perhaps the most critical skill when building React applications. Components that are too small create unnecessary complexity, while components that are too large become difficult to understand and maintain.

::: important
**The Goldilocks principle for components**

Good components are "just right" - not too big, not too small. They handle a cohesive set of functionality that makes sense to group together, without trying to do too much or too little.
:::

### Signs of poor component boundaries {.unnumbered .unlisted}

**Components that are too large** exhibit these warning signs:
- Difficult to name clearly and concisely
- Handle multiple unrelated concerns
- Have too many props (typically more than 5-7)
- Are hard to test because they do too much
- Require significant scrolling to read through the code

**Components that are too small** create these problems:
- Excessive prop drilling between parent and child
- No clear benefit from the separation
- Difficult to understand the overall functionality
- Create unnecessary rendering overhead

::: example
**Too large - UserDashboard component**:
```jsx
function UserDashboard() {
  // Manages user profile data
  const [user, setUser] = useState(null);
  // Manages notification settings
  const [notifications, setNotifications] = useState([]);
  // Handles billing information
  const [billingInfo, setBillingInfo] = useState(null);
  // Manages account settings
  const [settings, setSettings] = useState({});
  
  // 200+ lines of mixed functionality...
  
  return (
    <div>
      {/* Profile section */}
      {/* Notifications section */}
      {/* Billing section */}
      {/* Settings section */}
    </div>
  );
}
```

**Better - Separated components**:
```jsx
function UserDashboard() {
  return (
    <div className="dashboard">
      <UserProfile />
      <NotificationCenter />
      <BillingPanel />
      <AccountSettings />
    </div>
  );
}
```
:::

### The rule of three levels {.unnumbered .unlisted}

A useful heuristic for component boundaries is the "rule of three levels":

1. **Presentation level**: Components that focus purely on rendering UI elements
2. **Container level**: Components that manage state and data flow  
3. **Page level**: Components that orchestrate entire application sections

::: note
**Understanding the three levels**

**Presentation components** (also called "dumb" or "stateless" components):
- Receive data via props
- Focus on how things look
- Don't manage their own state (except for UI state like form inputs)
- Are highly reusable

**Container components** (also called "smart" or "stateful" components):
- Manage state and data fetching
- Focus on how things work
- Provide data to presentation components
- Handle business logic

**Page components**:
- Coordinate multiple features
- Handle routing and navigation
- Manage application-level state
- Compose container and presentation components
:::

::: example
**Three-level example - User profile feature**:

```jsx
// PAGE LEVEL - coordinates the entire profile page
function UserProfilePage({ userId }) {
  return (
    <div className="profile-page">
      <Header />
      <UserProfileContainer userId={userId} />
      <UserActivityContainer userId={userId} />
      <Footer />
    </div>
  );
}

// CONTAINER LEVEL - manages data and state
function UserProfileContainer({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);
  
  if (loading) return <LoadingSpinner />;
  
  return <UserProfile user={user} onUpdate={setUser} />;
}

// PRESENTATION LEVEL - focuses on display
function UserProfile({ user, onUpdate }) {
  return (
    <div className="user-profile">
      <Avatar src={user.avatar} alt={user.name} />
      <h1>{user.name}</h1>
      <ContactInfo email={user.email} phone={user.phone} />
      <EditButton onClick={() => onUpdate(user)} />
    </div>
  );
}
```
:::

### Data flow patterns {.unnumbered .unlisted}

Understanding how data flows through your component hierarchy is essential for good architecture. React's unidirectional data flow means data flows down through props and actions flow up through callbacks.

::: important
**Definition: Unidirectional data flow**

In React, data flows in one direction: from parent components to child components through props. When child components need to communicate with parents, they do so through callback functions passed down as props. This creates a predictable pattern where data changes originate at a known source and flow downward.
:::

**Data flows down**: Parent components pass data to children through props.
**Actions flow up**: Children communicate with parents through callback functions.

::: example
**Data flow in action**:

```jsx
// Parent component - owns the data
function ShoppingCart() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  
  const addItem = (item) => {
    setItems([...items, item]);
    setTotal(total + item.price);
  };
  
  const removeItem = (itemId) => {
    const newItems = items.filter(item => item.id !== itemId);
    setItems(newItems);
    setTotal(newItems.reduce((sum, item) => sum + item.price, 0));
  };
  
  return (
    <div>
      {/* Data flows down via props */}
      <CartItems 
        items={items} 
        onRemoveItem={removeItem}  // Callback flows down
      />
      <CartTotal total={total} />
      <AddItemForm onAddItem={addItem} />  // Callback flows down
    </div>
  );
}

// Child component - receives data and callbacks
function CartItems({ items, onRemoveItem }) {
  return (
    <div>
      {items.map(item => (
        <CartItem 
          key={item.id}
          item={item}
          onRemove={() => onRemoveItem(item.id)}  // Action flows up
        />
      ))}
    </div>
  );
}
```
:::

::: tip
**The 2-3 level rule**

If you find yourself passing props more than 2-3 levels deep, consider whether your component hierarchy needs restructuring or whether you need state management tools like Context or external libraries.

**Prop drilling** occurs when you pass props through multiple component levels just to get data to a deeply nested child. This is a sign that your component structure might need adjustment.
:::

### When to break the rules {.unnumbered .unlisted}

While unidirectional data flow is React's default pattern, there are legitimate cases where you might need alternative approaches:

**Context API**: For data that many components need (like user authentication, theme settings)
**State management libraries**: For complex applications with intricate state relationships
**Custom hooks**: For sharing stateful logic between components
**Refs**: For imperative DOM access (though use sparingly)

## Thinking about data sources

No modern React application exists in isolation. Your components will need to fetch data from APIs, submit forms to servers, and handle real-time updates. Understanding how to architect data fetching early in your component planning process is crucial.

### The resource pattern {.unnumbered .unlisted}

When designing React applications that interact with APIs, thinking in terms of "resources" provides a clean abstraction. A resource represents a collection of related data and the operations you can perform on it.

Consider this resource pattern for managing user data:

::: example

```javascript
// src/resources/User.js
import { protectedRoute } from "../network/apiConfig";

const User = {
  // Fetch all users
  async index() {
    try {
      const response = await protectedRoute.get("/users");
      return response.data;
    } catch (error) {
      console.error("Failed to fetch users:", error.message);
      throw new Error("Unable to fetch user data. Please try again later.");
    }
  },

  // Fetch a specific user by ID
  async show(id) {
    try {
      const response = await protectedRoute.get(`/users/${id}`);
      return response.data;
    } catch (error) {
      console.error(`Failed to fetch user with ID ${id}:`, error.message);
      throw new Error(`Unable to fetch user data for ID ${id}.`);
    }
  },

  // Create a new user
  async create(userData) {
    try {
      const response = await protectedRoute.post("/users", userData);
      return response.data;
    } catch (error) {
      console.error("Failed to create user:", error.message);
      throw new Error("Unable to create user. Please try again later.");
    }
  },

  // Update an existing user
  async update(id, userData) {
    try {
      const response = await protectedRoute.put(`/users/${id}`, userData);
      return response.data;
    } catch (error) {
      console.error(`Failed to update user with ID ${id}:`, error.message);
      throw new Error(`Unable to update user with ID ${id}.`);
    }
  },

  // Delete a user
  async destroy(id) {
    try {
      await protectedRoute.delete(`/users/${id}`);
    } catch (error) {
      console.error(`Failed to delete user with ID ${id}:`, error.message);
      throw new Error(`Unable to delete user with ID ${id}.`);
    }
  },
};

export default User;
```

:::

### Organizing network code {.unnumbered .unlisted}

A well-structured React application separates network concerns into dedicated modules:

::: example

```
src/
|-- components/
|-- resources/
|   |-- User.js
|   |-- PracticeSession.js
|   '-- Repertoire.js
|-- network/
|   |-- apiConfig.js
|   |-- interceptors.js
|   '-- errorHandling.js
'-- utils/
    |-- timing.js
    '-- musicNotation.js
```

:::

This organization keeps API logic separate from component logic, making both easier to test and maintain.

### Data fetching in components {.unnumbered .unlisted}

When planning component architecture, consider how each component will interact with data:

- **Data-fetching components**: Components responsible for loading data from APIs
- **Data-displaying components**: Pure presentation components that receive data via props
- **Data-mutating components**: Components that handle form submissions and data updates

::: example

```jsx
// Data-fetching component
function SessionList() {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    PracticeSession.index()
      .then(setSessions)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <LoadingSpinner />;

  return (
    <div className="session-list">
      {sessions.map((session) => (
        <SessionCard key={session.id} session={session} />
      ))}
    </div>
  );
}

// Data-displaying component
function SessionCard({ session }) {
  return (
    <div className="session-card">
      <h3>{session.piece}</h3>
      <p>Duration: {session.duration} minutes</p>
      <p>Focus: {session.focus}</p>
      <span className="practice-date">{session.date}</span>
    </div>
  );
}
```

:::

::: important
**Separation of concerns**

Keep network logic separate from component logic. Components should focus on rendering and user interaction, while resource modules handle API communication. This separation makes your code more testable and maintainable.
:::

We'll explore data fetching patterns, error handling, and state management for network requests in greater detail in Chapter 3, "State and Props," and Chapter 8, "State Management."

## Building your first component architecture

Let's put these principles into practice by architecting a real application. We'll design a music practice tracker that demonstrates proper component thinking.

::: important
**Focus on thinking, not implementation**

In this section, we're focusing purely on architectural planning and component design thinking. We won't be writing code to build this application-instead, we're practicing the mental framework that comes before implementation. This same music practice tracker example may reappear in later chapters when we explore specific implementation techniques.
:::

### Planning phase {.unnumbered .unlisted}

Before writing code, let's map out our application:

**User interface requirements**:

- Practice session log with filtering and search
- Session creation form with timer functionality
- Individual practice entries with editing capabilities
- Progress dashboard and statistics
- Repertoire management (pieces being practiced)
- Goal setting and tracking

**Data requirements**:

- Fetch practice sessions from API
- Create new practice sessions
- Update existing sessions and progress notes
- Delete practice entries
- Manage repertoire (add/remove pieces)
- Track practice goals and achievements

**Component identification exercise**:

1. Draw the complete interface
2. Identify distinct functional areas
3. Determine data requirements for each area
4. Map component relationships
5. Plan data flow paths
6. Identify which components need network access

::: tip
**Practice makes perfect**

The goal here is to develop your architectural thinking skills. Try sketching out the interface on paper or using a digital tool. Focus on breaking down the problem into logical pieces rather than worrying about perfect solutions.
:::

### Component responsibility mapping {.unnumbered .unlisted}

For our music practice tracker, we might identify these components:

::: example

```
PracticeApp
|-- Header
|   |-- Logo
|   '-- UserProfile
|-- PracticeDashboard
|   |-- PracticeStats (fetches statistics)
|   '-- PracticeFilters
|-- SessionList (fetches practice sessions)
|   '-- SessionItem[] (updates individual sessions)
|-- RepertoirePanel
|   |-- PieceCard[] (displays practice pieces)
|   '-- AddPieceForm
'-- SessionForm (creates new practice sessions)
```

:::

Each component has clear responsibilities:

- `PracticeApp`: Application state and data coordination
- `PracticeDashboard`: Filtering, statistics, and goal tracking
- `SessionList`: Session rendering, list management, and data fetching
- `SessionItem`: Individual session behavior and progress updates
- `RepertoirePanel`: Managing pieces being practiced
- `SessionForm`: Practice session creation with timer functionality

**Resource planning**:

::: example

```javascript
// src/resources/PracticeSession.js
const PracticeSession = {
  async index(filters = {}) {
    /* fetch filtered practice sessions */
  },
  async show(id) {
    /* fetch single practice session */
  },
  async create(sessionData) {
    /* create new practice session */
  },
  async update(id, sessionData) {
    /* update session notes and progress */
  },
  async destroy(id) {
    /* delete practice session */
  },
  async getStats(dateRange) {
    /* fetch practice statistics */
  },
};

// src/resources/Repertoire.js
const Repertoire = {
  async index() {
    /* fetch user's repertoire */
  },
  async create(pieceData) {
    /* add new piece to repertoire */
  },
  async update(id, pieceData) {
    /* update piece details or progress */
  },
  async destroy(id) {
    /* remove piece from repertoire */
  },
};
```

:::

::: note
**Architectural thinking in action**

Notice how we've broken down a complex application into manageable pieces without writing a single line of React code. This planning phase is where good React applications are really built-the implementation is just translating these architectural decisions into code. We'll explore how to implement these patterns in subsequent chapters.
:::

## Common architectural patterns

As you develop more React applications, certain patterns emerge repeatedly. Understanding these patterns helps you make better architectural decisions.

### Container and presentation pattern {.unnumbered .unlisted}

Separating components that manage state (containers) from components that render UI (presentation) creates cleaner, more testable code.

### Compound components pattern {.unnumbered .unlisted}

For complex UI elements like modals, dropdowns, or tabs, compound components allow you to create flexible, composable interfaces.

### Higher-order component pattern {.unnumbered .unlisted}

When you need to share logic between components, higher-order components provide a powerful abstraction mechanism.

## Practical exercises

::: setup

**Setup requirements**

For the following exercises, you'll need:

- Node.js installed on your system
- A code editor (VS Code recommended)
- Basic familiarity with ES6+ Java
