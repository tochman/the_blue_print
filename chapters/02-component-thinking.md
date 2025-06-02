# Component thinking

The shift from imperative to declarative thinking represents one of the most fundamental changes developers must make when learning React. In Chapter 1, we introduced this paradigm shift conceptually. Now we'll explore it through concrete examples and see how it applies to building real React applications. This chapter focuses on developing the architectural mindset that separates effective React developers from those who struggle with component design and application structure.

## From DOM manipulation to component composition

Most developers come to React with experience in direct DOM manipulation—selecting elements, modifying their properties, and orchestrating complex interactions through event handlers scattered across their codebase. React asks you to think differently.

::: important
**The declarative shift**

Instead of describing _how_ to change the interface, React asks you to describe _what_ the interface should look like at any given moment. This fundamental shift in thinking takes time to internalize, but once mastered, it leads to more predictable and maintainable applications.
:::

Consider a simple example: showing and hiding a modal dialog. In traditional JavaScript, you might write:

::: example

```javascript
// Imperative approach
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
```

:::

With React's declarative approach, you describe the desired state:

::: example

```jsx
// Declarative approach
function App() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className={`app ${isModalOpen ? "no-scroll" : ""}`}>
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
      <Overlay active={isModalOpen} />
    </div>
  );
}
```

:::

This shift requires rewiring how you think about user interfaces, but the benefits compound quickly as applications grow in complexity.

## The architecture-first mindset

Before writing any component code, successful React developers engage in what RoxSWEngineering calls "thinking architecture." This involves mapping out component relationships, data flow, and interaction patterns before implementation begins.

### Visual planning exercises {.unnumbered .unlisted}

The most effective way to develop architectural thinking is through visual planning. Take a whiteboard, paper, or digital tool and practice breaking down interfaces into components.

::: example
**Exercise: component identification**

Visit a popular website (like GitHub, Twitter, or Medium) and practice identifying potential React components. Draw boxes around distinct pieces of functionality and consider:

- What data does each component need?
- How do components communicate with each other?
- Which components could be reused in other parts of the application?
- Where should state live for each piece of data?

:::

### The component hierarchy principle {.unnumbered .unlisted}

Every React application is a tree of components, and understanding this hierarchy is crucial for effective architecture. When planning your component structure, consider these guidelines:

**Single responsibility principle**: Each component should have one clear purpose. If you find yourself struggling to name a component or describing its purpose requires multiple sentences, it likely needs to be broken down further.

**Data ownership**: Components should own the data they need to function. When data needs to be shared between components, it should live in their closest common ancestor.

**Reusability consideration**: While not every component needs to be reusable, thinking about reusability during design often leads to better component boundaries and cleaner interfaces.

## Component boundaries and responsibilities

Identifying the right boundaries for your components is perhaps the most critical skill in React development. Components that are too small create unnecessary complexity, while components that are too large become difficult to understand and maintain.

### The rule of three levels {.unnumbered .unlisted}

A useful heuristic for component boundaries is the "rule of three levels":

1. **Presentation level**: Components that focus purely on rendering UI elements
2. **Container level**: Components that manage state and data flow
3. **Page level**: Components that orchestrate entire application sections

### Data flow patterns {.unnumbered .unlisted}

Understanding how data flows through your component hierarchy is essential for good architecture. React's unidirectional data flow means data flows down through props and actions flow up through callbacks.

::: tip
**The 2-3 level rule**

If you find yourself passing props more than 2-3 levels deep, consider whether your component hierarchy needs restructuring or whether you need state management tools like Context or external libraries.
:::

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
|   |-- Task.js
|   '-- Project.js
|-- network/
|   |-- apiConfig.js
|   |-- interceptors.js
|   '-- errorHandling.js
'-- utils/
    |-- formatting.js
    '-- validation.js
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
function UserList() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    User.index()
      .then(setUsers)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <LoadingSpinner />;

  return (
    <div className="user-list">
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}

// Data-displaying component
function UserCard({ user }) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
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

Let's put these principles into practice by architecting a real application. We'll design a task management application that demonstrates proper component thinking.

### Planning phase {.unnumbered .unlisted}

Before writing code, let's map out our application:

**User interface requirements**:

- Task list with filtering capabilities
- Task creation form
- Individual task items with editing capabilities
- Statistics dashboard

**Data requirements**:

- Fetch tasks from API
- Create new tasks
- Update existing tasks
- Delete tasks
- Real-time updates (optional)

**Component identification exercise**:

1. Draw the complete interface
2. Identify distinct functional areas
3. Determine data requirements for each area
4. Map component relationships
5. Plan data flow paths
6. Identify which components need network access

### Component responsibility mapping {.unnumbered .unlisted}

For our task management application, we might identify these components:

::: example

```
TaskApp
|-- Header
|   |-- Logo
|   '-- UserProfile
|-- TaskDashboard
|   |-- TaskStats (fetches statistics)
|   '-- TaskFilters
|-- TaskList (fetches tasks)
|   '-- TaskItem[] (updates individual tasks)
'-- TaskForm (creates new tasks)
```

:::

Each component has clear responsibilities:

- `TaskApp`: Application state and data coordination
- `TaskDashboard`: Filtering and statistics logic
- `TaskList`: Task rendering, list management, and data fetching
- `TaskItem`: Individual task behavior and updates
- `TaskForm`: Task creation and submission

**Resource planning**:

::: example

```javascript
// src/resources/Task.js
const Task = {
  async index(filters = {}) {
    /* fetch filtered tasks */
  },
  async show(id) {
    /* fetch single task */
  },
  async create(taskData) {
    /* create new task */
  },
  async update(id, taskData) {
    /* update task */
  },
  async destroy(id) {
    /* delete task */
  },
  async getStats() {
    /* fetch task statistics */
  },
};
```

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
- Basic familiarity with ES6+ JavaScript features

:::

### Exercise 1: Component identification {.unnumbered .unlisted}

Choose a complex web page (such as a social media site, e-commerce site, or news portal) and practice identifying potential React components. Create a visual diagram showing:

1. Component boundaries
2. Component hierarchy
3. Potential props for each component
4. State requirements

### Exercise 2: Architecture planning {.unnumbered .unlisted}

Plan the architecture for a simple blog application with these features:

- Article list with search functionality
- Individual article view
- Comment system
- Author profile pages

Create diagrams showing:

- Component hierarchy
- Data flow patterns
- State management strategy

### Exercise 3: Refactoring exercise {.unnumbered .unlisted}

Take a small existing web page (or create one with vanilla JavaScript) and plan how you would convert it to a React application. Consider:

- How to break down the interface into components
- Where state should live
- How components would communicate

### Exercise 4: API integration planning {.unnumbered .unlisted}

Design the architecture for a blog application that fetches data from a REST API:

**Requirements**:

- Article list with pagination
- Individual article view with comments
- User authentication
- Article creation/editing for authenticated users

**Planning tasks**:

1. Design the resource modules needed (Article, User, Comment)
2. Identify which components need network access
3. Plan loading states and error handling
4. Consider optimistic updates for better UX

Create diagrams showing:

- Component hierarchy with data flow
- Resource module structure
- Network request patterns
- Error boundary placement

## Looking ahead

The architectural thinking skills developed in this chapter form the foundation for everything else we'll explore in this book. In the next chapter, we'll dive deep into state and props—the mechanisms that make your component architecture come alive with dynamic data and user interaction.

Remember that good architecture is iterative. Start with simple designs and refine them as you better understand your application's needs. The patterns and principles covered here will serve you well as you tackle increasingly complex React applications.

::: note
**Chapter summary**

- React requires shifting from imperative to declarative thinking
- Visual planning before coding reveals architectural issues early
- Component boundaries should follow single responsibility principles
- Data flows down through props, actions flow up through callbacks
- Separate network logic from component logic using resource patterns
- Plan data fetching responsibilities during component architecture design
- Good architecture is iterative and grows with your understanding
  :::
