# State and props

Now we get to the heart of React: state and props. These two concepts are absolutely fundamental to everything you'll build with React, and honestly, they're where React starts to feel like magic. Once you understand how state and props work together, you'll have that "aha!" moment where React's entire philosophy suddenly makes sense.

I remember when I first learned React, I kept confusing state and props. "Why do I sometimes pass data as props and sometimes store it as state? What's the difference?" It felt arbitrary and confusing. But here's the thing—the distinction is actually quite elegant once you see the pattern.

Think of state as a component's private memory: data that belongs to the component and can change over time. Props, on the other hand, are like arguments to a function: data that gets passed in from the outside. Together, they create a data flow that's predictable, testable, and surprisingly powerful.

::: tip
**What you'll learn in this chapter**

- How to think about state as your component's memory and when to use it
- The art of deciding where state should live in your component tree
- How props create communication channels between components
- Practical patterns for handling user input, loading states, and errors
- Why React's approach to data flow makes complex applications manageable
- When to optimize and when optimization is premature
:::

## Understanding state in React

Let's start with state, because it's probably the more confusing of the two concepts initially. State in React isn't just a variable that holds data. It's your component's way of remembering things between renders and telling React "hey, something changed, you should probably re-render me."

Here's the crucial insight that took me way too long to understand: when you update state, you're not just changing a value. You're telling React that your component needs to re-evaluate what it should look like based on this new information. It's like updating a spreadsheet cell and watching all the dependent formulas recalculate automatically.

::: important
**State is React's memory system**

Every time you call a state setter (like `setCount`), React schedules a re-render of your component. During this re-render, React calls your component function again with the new state values, generates a fresh description of what the UI should look like, and updates the DOM to match. It's like having an assistant who automatically redraws your interface whenever you change the underlying data.
:::

Let me show you what I mean with the classic counter example, but I want you to really think about what's happening here:

::: example
```jsx
function Counter() {
  const [count, setCount] = useState(0);

  const increment = () => {
    setCount(count + 1);
  };

  return (
    <div className="counter">
      <p>Current count: {count}</p>
      <button onClick={increment}>
        Increment
      </button>
    </div>
  );
}
```
:::

In this example, `count` is state: it starts at zero and changes when the user clicks the button. Each time `setCount` is called, React re-renders the component with the new count value, and the interface updates to reflect this change. The component describes what it should look like for any given count value, and React handles the transformation.

## Local state vs. shared state

One of the most important decisions you'll make when building React applications is determining where state should live. React components can manage their own local state, or state can be "lifted up" to parent components when multiple children need access to the same data.

Local state works well when the data only affects a single component and its immediate children. However, when multiple components need to read or modify the same data, that state needs to live in a common ancestor that can pass it down to all the components that need it.

::: example
```jsx
// Local state - only this component needs the expanded/collapsed state
function CollapsiblePanel({ title, children }) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div className="panel">
      <button onClick={() => setIsExpanded(!isExpanded)}>
        {isExpanded ? 'Hide' : 'Show'} {title}
      </button>
      {isExpanded && (
        <div className="panel-content">
          {children}
        </div>
      )}
    </div>
  );
}

// Shared state - multiple components need access to user data
function UserDashboard() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Both UserProfile and UserSettings need user data
  return (
    <div className="dashboard">
      <UserProfile user={user} />
      <UserSettings user={user} onUserUpdate={setUser} />
    </div>
  );
}
```
:::

The key insight is that state should live at the lowest level in the component tree where all components that need it can access it. This principle keeps your component hierarchy clean and prevents unnecessary prop drilling: the practice of passing props through multiple component levels just to reach a deeply nested child.

::: tip
**Where should state live?**

- If only one component needs the data, keep it local.
- If multiple components need the data, lift the state up to their closest common ancestor.
- Avoid duplicating state in multiple places. This leads to bugs and out-of-sync data.
:::

## Props and component communication

Now let's talk about props: React's way of letting components communicate. If state is a component's private memory, then props are like the arguments you pass to a function. They're how parent components share data and functionality with their children.

Props create a clear, predictable flow of data in your application. Data flows down from parent to child through props, and communication flows back up through callback functions (which are also passed as props). This structure makes your application's data flow easy to trace and debug.

The key insight is that props are read-only. A child component should never modify the props it receives directly. If it needs to change something, it asks its parent to make the change by calling a callback function. This might seem restrictive at first, but it's what makes React applications predictable and debuggable.

::: important
**Props are read-only contracts**

Think of props as a contract between parent and child components. The parent says "here's the data you need and here's how you can communicate back to me." The child should never break that contract by modifying props directly. If it needs to change data, it uses the communication channels (callback functions) provided by the parent.
:::

Let me show you how this works with a practical example: a music practice tracker where a parent component manages a list of sessions and child components display individual sessions:

::: example
```jsx
function PracticeSessionList() {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPracticeSessions()
      .then(setSessions)
      .finally(() => setLoading(false));
  }, []);

  const updateSession = (sessionId, updates) => {
    setSessions(sessions.map(session => 
      session.id === sessionId 
        ? { ...session, ...updates }
        : session
    ));
  };

  if (loading) return <LoadingSpinner />;

  return (
    <div className="session-list">
      {sessions.map(session => (
        <PracticeSessionItem
          key={session.id}
          session={session}
          onUpdate={(updates) => updateSession(session.id, updates)}
        />
      ))}
    </div>
  );
}

function PracticeSessionItem({ session, onUpdate }) {
  const [isEditing, setIsEditing] = useState(false);

  const handleSave = (newNotes) => {
    onUpdate({ notes: newNotes });
    setIsEditing(false);
  };

  return (
    <div className="session-item">
      <h3>{session.piece}</h3>
      <p>Duration: {session.duration} minutes</p>
      
      {isEditing ? (
        <EditNotesForm 
          initialNotes={session.notes}
          onSave={handleSave}
          onCancel={() => setIsEditing(false)}
        />
      ) : (
        <div>
          <p>{session.notes}</p>
          <button onClick={() => setIsEditing(true)}>
            Edit Notes
          </button>
        </div>
      )}
    </div>
  );
}
```
:::

In this example, the `PracticeSessionList` owns the sessions state and passes individual session data down to `PracticeSessionItem` components as props. When a session item needs to update its notes, it calls the `onUpdate` callback function passed down from the parent, which updates the parent's state and triggers a re-render with the new data.

## Designing prop interfaces

Well-designed props create clear contracts between components. They define what data a component expects to receive and what functions it might call. This contract-like nature makes components more predictable and easier to test, as you can provide specific props and verify the component's behavior.

When designing component props, consider both the immediate needs and potential future requirements. Props that are too specific can make components inflexible, while props that are too generic can make components difficult to understand and use correctly.

::: tip
**Designing clear prop interfaces**

Good prop design balances specificity with flexibility. Components should receive the data they need to function without being tightly coupled to the specific shape of your application's data structures. Consider using transformation functions or adapter patterns when necessary to maintain clean component interfaces.
:::

## The useState hook in depth

The `useState` hook is your primary tool for managing component state in modern React. While it appears simple on the surface, understanding its nuances will help you build more efficient and predictable components.

When you call `useState`, you're creating a piece of state that belongs to that specific component instance. React tracks this state internally and provides you with both the current value and a function to update it. The state update function doesn't modify the state immediately. Instead, it schedules an update that will take effect during the next render.

::: example
```jsx
function TimerComponent() {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    let interval = null;
    
    if (isRunning) {
      interval = setInterval(() => {
        setSeconds(prevSeconds => prevSeconds + 1);
      }, 1000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRunning]);

  const start = () => setIsRunning(true);
  const pause = () => setIsRunning(false);
  const reset = () => {
    setSeconds(0);
    setIsRunning(false);
  };

  return (
    <div className="timer">
      <div className="display">
        {Math.floor(seconds / 60)}:{(seconds % 60).toString().padStart(2, '0')}
      </div>
      <div className="controls">
        <button onClick={start} disabled={isRunning}>
          Start
        </button>
        <button onClick={pause} disabled={!isRunning}>
          Pause
        </button>
        <button onClick={reset}>
          Reset
        </button>
      </div>
    </div>
  );
}
```
:::

This timer component demonstrates several important concepts about state management. The component maintains two pieces of state: the elapsed seconds and whether the timer is currently running. Notice how the `useEffect` hook depends on the `isRunning` state, creating a reactive relationship where changes to one piece of state trigger side effects.

## State updates: Functional vs. direct

One crucial aspect of `useState` is understanding when to use functional updates versus direct updates. When your new state depends on the previous state, you should use the functional form to ensure you're working with the most recent value.

::: example
```jsx
function CounterWithIncrement() {
  const [count, setCount] = useState(0);

  // Potentially problematic - may use stale state
  const incrementBad = () => {
    setCount(count + 1);
    setCount(count + 1); // This might not work as expected
  };

  // Correct - uses functional update
  const incrementGood = () => {
    setCount(prevCount => prevCount + 1);
    setCount(prevCount => prevCount + 1); // This works correctly
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={incrementGood}>
        Increment by 2
      </button>
    </div>
  );
}
```
:::

The functional update pattern becomes especially important when dealing with rapid state changes or when multiple state updates might occur in quick succession. The functional form ensures that each update receives the most recent state value, preventing issues with stale closures.

## Managing complex state: Objects and arrays

As your components grow in complexity, you might need to manage state that consists of objects or arrays. React requires that you treat state as immutable. Instead of modifying existing objects or arrays, you create new ones with the desired changes.

::: example
```jsx
function PracticeSessionForm() {
  const [session, setSession] = useState({
    piece: '',
    duration: 30,
    focus: '',
    notes: '',
    techniques: []
  });

  const updateField = (field, value) => {
    setSession(prevSession => ({
      ...prevSession,
      [field]: value
    }));
  };

  const addTechnique = (technique) => {
    setSession(prevSession => ({
      ...prevSession,
      techniques: [...prevSession.techniques, technique]
    }));
  };

  const removeTechnique = (index) => {
    setSession(prevSession => ({
      ...prevSession,
      techniques: prevSession.techniques.filter((_, i) => i !== index)
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Submit the session data
    console.log('Submitting session:', session);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        placeholder="Piece name"
        value={session.piece}
        onChange={(e) => updateField('piece', e.target.value)}
      />
      
      <input
        type="number"
        placeholder="Duration (minutes)"
        value={session.duration}
        onChange={(e) => updateField('duration', parseInt(e.target.value))}
      />
      
      <textarea
        placeholder="Practice focus"
        value={session.focus}
        onChange={(e) => updateField('focus', e.target.value)}
      />
      
      <div className="techniques">
        <h4>Techniques practiced:</h4>
        {session.techniques.map((technique, index) => (
          <div key={index} className="technique-item">
            <span>{technique}</span>
            <button 
              type="button"
              onClick={() => removeTechnique(index)}
            >
              Remove
            </button>
          </div>
        ))}
        
        <button 
          type="button"
          onClick={() => addTechnique('Scale practice')}
        >
          Add Scale Practice
        </button>
      </div>
      
      <button type="submit">Save Session</button>
    </form>
  );
}
```
:::

This form component demonstrates how to manage complex state while maintaining immutability. Each update creates a new state object rather than modifying the existing one, which ensures that React can properly detect changes and trigger re-renders.

## Data flow patterns and communication strategies

Effective data flow is the backbone of maintainable React applications. Understanding how to structure communication between components prevents many common architectural problems and makes your applications easier to debug and extend.

The fundamental principle of React's data flow is that data flows down through props and actions flow up through callback functions. This unidirectional pattern creates predictable relationships between components and makes it easier to trace how data changes propagate through your application.

## Lifting state up

Here's one of React's most important patterns, and honestly, one that I wish I had understood better earlier in my React journey: lifting state up. The idea is simple. When multiple components need to share the same piece of state, you move that state to their closest common parent.

I used to fight against this pattern. I'd try to keep state as close to where it was used as possible, thinking that was cleaner. But then I'd run into situations where two sibling components needed to share data, and I'd end up with hacky workarounds or duplicate state that got out of sync. Lifting state up solves this elegantly by creating a single source of truth.

Think of it like being the coordinator for a group project. Instead of everyone keeping their own copy of the project status (which inevitably gets out of sync), one person maintains the authoritative version and shares updates with everyone else. That's exactly what lifting state up does for your components.

::: example
```jsx
function MusicLibrary() {
  const [selectedPiece, setSelectedPiece] = useState(null);
  const [pieces, setPieces] = useState([]);
  const [practiceHistory, setPracticeHistory] = useState([]);

  const handlePieceSelect = (piece) => {
    setSelectedPiece(piece);
  };

  const addPracticeSession = (sessionData) => {
    const newSession = {
      ...sessionData,
      id: Date.now(),
      date: new Date().toISOString(),
      pieceId: selectedPiece.id
    };
    
    setPracticeHistory(prev => [...prev, newSession]);
  };

  return (
    <div className="music-library">
      <PieceSelector 
        pieces={pieces}
        selectedPiece={selectedPiece}
        onPieceSelect={handlePieceSelect}
      />
      
      {selectedPiece && (
        <div className="practice-area">
          <PieceDetails piece={selectedPiece} />
          <PracticeTimer 
            piece={selectedPiece}
            onSessionComplete={addPracticeSession}
          />
          <PracticeHistory 
            sessions={practiceHistory.filter(s => s.pieceId === selectedPiece.id)}
          />
        </div>
      )}
    </div>
  );
}
```
:::

In this structure, the `MusicLibrary` component manages the state that multiple child components need. The selected piece flows down to components that need to display or work with it, while actions like selecting a piece or completing a practice session flow back up through callback functions.

## Component composition and prop drilling

As your component hierarchy grows deeper, you might encounter "prop drilling": the need to pass props through multiple levels of components just to reach a deeply nested child. While prop drilling isn't inherently bad for shallow hierarchies, it can become cumbersome when props need to travel through many intermediate components.

::: important
**When prop drilling becomes problematic**

Prop drilling is generally acceptable for 2–3 levels of component nesting. Beyond that, consider alternative patterns like component composition, the Context API (covered in Chapter 8), or restructuring your component hierarchy to reduce nesting depth.
:::

Component composition can often reduce the need for prop drilling by allowing you to pass components themselves as props, rather than data that gets used deep within the component tree.

::: example
```jsx
// Prop drilling approach - props pass through multiple levels
function App() {
  const [user, setUser] = useState(null);
  
  return (
    <Layout user={user}>
      <Dashboard user={user} onUserUpdate={setUser} />
    </Layout>
  );
}

function Layout({ user, children }) {
  return (
    <div className="layout">
      <Header user={user} />
      <main>{children}</main>
    </div>
  );
}

// Composition approach - components are passed as props
function App() {
  const [user, setUser] = useState(null);
  
  return (
    <Layout header={<Header user={user} />}>
      <Dashboard user={user} onUserUpdate={setUser} />
    </Layout>
  );
}

function Layout({ header, children }) {
  return (
    <div className="layout">
      {header}
      <main>{children}</main>
    </div>
  );
}
```
:::

The composition approach reduces the coupling between the `Layout` component and the user data, making the layout more reusable and the data flow more explicit.

## Handling side effects with useEffect

While state manages the data that changes over time, many React components also need to perform side effects: operations that interact with the outside world or have effects beyond rendering. The `useEffect` hook provides a structured way to handle these side effects while maintaining React's declarative principles.

Side effects include network requests, setting up subscriptions, manually changing the DOM, starting timers, and cleaning up resources. The `useEffect` hook lets you perform these operations in a way that's coordinated with React's rendering cycle.

::: important
**useEffect runs after render**

Effects run after the component has rendered to the DOM. This ensures that your side effects don't block the browser's ability to paint the screen, keeping your application responsive. Effects also have access to the current props and state values from the render they're associated with.
:::

## Basic effect patterns

The most common use of `useEffect` is to fetch data when a component mounts or when certain dependencies change. Understanding the dependency array is crucial for controlling when effects run and preventing infinite loops.

::: example
```jsx
function PracticeSessionDetails({ sessionId }) {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;

    const fetchSession = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const sessionData = await PracticeSession.show(sessionId);
        
        if (!cancelled) {
          setSession(sessionData);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    fetchSession();

    // Cleanup function to prevent state updates if component unmounts
    return () => {
      cancelled = true;
    };
  }, [sessionId]); // Effect runs when sessionId changes

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!session) return <NotFound />;

  return (
    <div className="session-details">
      <h2>{session.piece}</h2>
      <p>Practiced on: {new Date(session.date).toLocaleDateString()}</p>
      <p>Duration: {session.duration} minutes</p>
      <p>Focus: {session.focus}</p>
      <p>Notes: {session.notes}</p>
    </div>
  );
}
```
:::

This component demonstrates several important patterns for data fetching with `useEffect`. The effect includes proper error handling, loading states, and cleanup to prevent memory leaks if the component unmounts during a fetch operation.

## Effect cleanup and resource management

Many effects need cleanup to prevent memory leaks or other issues. Event listeners, timers, subscriptions, and network requests should all be cleaned up when components unmount or when effect dependencies change.

::: example
```jsx
function PracticeTimer({ onTick, onComplete }) {
  const [seconds, setSeconds] = useState(0);
  const [isActive, setIsActive] = useState(false);

  useEffect(() => {
    let interval = null;

    if (isActive) {
      interval = setInterval(() => {
        setSeconds(prevSeconds => {
          const newSeconds = prevSeconds + 1;
          
          // Call the onTick callback if provided
          if (onTick) {
            onTick(newSeconds);
          }
          
          return newSeconds;
        });
      }, 1000);
    }

    // Cleanup function runs when effect re-runs or component unmounts
    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [isActive, onTick]); // Re-run when isActive or onTick changes

  useEffect(() => {
    // Auto-complete after 45 minutes (2700 seconds)
    if (seconds >= 2700) {
      setIsActive(false);
      if (onComplete) {
        onComplete(seconds);
      }
    }
  }, [seconds, onComplete]);

  const toggle = () => setIsActive(!isActive);
  const reset = () => {
    setSeconds(0);
    setIsActive(false);
  };

  return (
    <div className="practice-timer">
      <div className="display">
        {Math.floor(seconds / 60)}:{(seconds % 60).toString().padStart(2, '0')}
      </div>
      <button onClick={toggle}>
        {isActive ? 'Pause' : 'Start'}
      </button>
      <button onClick={reset}>Reset</button>
    </div>
  );
}
```
:::

This timer component uses multiple effects to handle different concerns. One effect manages the timer interval, while another watches for the completion condition. Each effect includes proper cleanup to prevent resource leaks.

## Form handling and controlled components

Forms represent one of the most common patterns in React applications, and understanding how to handle form state effectively is essential for building interactive user interfaces. React promotes the use of "controlled components": form elements whose values are controlled by React state rather than their own internal state.

Controlled components create a single source of truth for form data, making it easier to validate inputs, handle submissions, and integrate forms with the rest of your application state. While this requires more setup than uncontrolled forms, the benefits in terms of predictability and debugging are substantial.

## Building controlled form components

A controlled form component manages all input values in React state and handles changes through event handlers. This approach gives you complete control over the form data and makes it easy to implement features like validation, formatting, and conditional logic.

::: example
```jsx
function NewPieceForm({ onSubmit, onCancel }) {
  const [formData, setFormData] = useState({
    title: '',
    composer: '',
    difficulty: 'intermediate',
    genre: '',
    notes: ''
  });

  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const updateField = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));

    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: null
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.title.trim()) {
      newErrors.title = 'Title is required';
    }

    if (!formData.composer.trim()) {
      newErrors.composer = 'Composer is required';
    }

    if (!formData.genre.trim()) {
      newErrors.genre = 'Genre is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);

    try {
      await onSubmit(formData);
    } catch (error) {
      setErrors({ submit: error.message });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="piece-form">
      <div className="form-field">
        <label htmlFor="title">Title</label>
        <input
          id="title"
          type="text"
          value={formData.title}
          onChange={(e) => updateField('title', e.target.value)}
          className={errors.title ? 'error' : ''}
        />
        {errors.title && <span className="error-message">{errors.title}</span>}
      </div>

      <div className="form-field">
        <label htmlFor="composer">Composer</label>
        <input
          id="composer"
          type="text"
          value={formData.composer}
          onChange={(e) => updateField('composer', e.target.value)}
          className={errors.composer ? 'error' : ''}
        />
        {errors.composer && <span className="error-message">{errors.composer}</span>}
      </div>

      <div className="form-field">
        <label htmlFor="difficulty">Difficulty</label>
        <select
          id="difficulty"
          value={formData.difficulty}
          onChange={(e) => updateField('difficulty', e.target.value)}
        >
          <option value="beginner">Beginner</option>
          <option value="intermediate">Intermediate</option>
          <option value="advanced">Advanced</option>
        </select>
      </div>

      <div className="form-field">
        <label htmlFor="genre">Genre</label>
        <input
          id="genre"
          type="text"
          value={formData.genre}
          onChange={(e) => updateField('genre', e.target.value)}
          className={errors.genre ? 'error' : ''}
        />
        {errors.genre && <span className="error-message">{errors.genre}</span>}
      </div>

      <div className="form-field">
        <label htmlFor="notes">Notes</label>
        <textarea
          id="notes"
          value={formData.notes}
          onChange={(e) => updateField('notes', e.target.value)}
          rows={4}
        />
      </div>

      {errors.submit && (
        <div className="error-message">{errors.submit}</div>
      )}

      <div className="form-actions">
        <button type="button" onClick={onCancel}>
          Cancel
        </button>
        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Adding...' : 'Add Piece'}
        </button>
      </div>
    </form>
  );
}
```
:::

This form component demonstrates several important patterns for form handling in React. It maintains all form data in state, provides real-time validation feedback, handles loading states during submission, and prevents multiple submissions.

## Custom hooks for form management

As your forms become more complex, you might find yourself repeating similar patterns for form state management. Custom hooks provide a way to extract and reuse form logic across multiple components.

::: example
```jsx
function useForm(initialValues, validationRules = {}) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});

  const updateField = (field, value) => {
    setValues(prev => ({
      ...prev,
      [field]: value
    }));

    // Clear error when field changes
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: null
      }));
    }
  };

  const markFieldTouched = (field) => {
    setTouched(prev => ({
      ...prev,
      [field]: true
    }));
  };

  const validateField = (field, value) => {
    const rule = validationRules[field];
    if (!rule) return null;

    if (rule.required && (!value || !value.toString().trim())) {
      return `${field} is required`;
    }

    if (rule.minLength && value.length < rule.minLength) {
      return `${field} must be at least ${rule.minLength} characters`;
    }

    if (rule.pattern && !rule.pattern.test(value)) {
      return rule.message || `${field} format is invalid`;
    }

    return null;
  };

  const validateForm = () => {
    const newErrors = {};

    Object.keys(validationRules).forEach(field => {
      const error = validateField(field, values[field]);
      if (error) {
        newErrors[field] = error;
      }
    });

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const reset = () => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
  };

  return {
    values,
    errors,
    touched,
    updateField,
    markFieldTouched,
    validateForm,
    reset,
    isValid: Object.keys(errors).length === 0
  };
}

// Usage in a component
function SimplePieceForm({ onSubmit }) {
  const form = useForm(
    { title: '', composer: '' },
    {
      title: { required: true, minLength: 2 },
      composer: { required: true }
    }
  );

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (form.validateForm()) {
      onSubmit(form.values);
      form.reset();
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        placeholder="Title"
        value={form.values.title}
        onChange={(e) => form.updateField('title', e.target.value)}
        onBlur={() => form.markFieldTouched('title')}
      />
      {form.touched.title && form.errors.title && (
        <span className="error">{form.errors.title}</span>
      )}

      <input
        type="text"
        placeholder="Composer"
        value={form.values.composer}
        onChange={(e) => form.updateField('composer', e.target.value)}
        onBlur={() => form.markFieldTouched('composer')}
      />
      {form.touched.composer && form.errors.composer && (
        <span className="error">{form.errors.composer}</span>
      )}

      <button type="submit" disabled={!form.isValid}>
        Submit
      </button>
    </form>
  );
}
```
:::

This custom hook encapsulates common form logic and can be reused across different forms in your application. It handles field updates, validation, error management, and provides a clean interface for form components.

## Performance considerations and optimization

As your React applications grow in complexity, understanding how state changes affect performance becomes increasingly important. React is generally fast, but inefficient state management can lead to unnecessary re-renders and degraded user experience.

The key to performance optimization in React is understanding when components re-render and minimizing unnecessary work. Every state update triggers a re-render of the component and potentially its children, so designing your state structure thoughtfully can have significant performance implications.

## Minimizing re-renders through state design

The structure of your state directly affects how often components re-render. State that changes frequently should be isolated from state that remains stable, and components should only re-render when the data they actually use has changed.

::: example
```jsx
// Problematic - large state object causes re-renders even for unrelated changes
function PracticeApp() {
  const [appState, setAppState] = useState({
    user: { name: 'John', email: 'john@email.com' },
    currentPiece: null,
    practiceTimer: { seconds: 0, isRunning: false },
    practiceHistory: [],
    uiState: { sidebarOpen: false, darkMode: false }
  });

  // Changing timer triggers re-render of entire app
  const updateTimer = (seconds) => {
    setAppState(prev => ({
      ...prev,
      practiceTimer: { ...prev.practiceTimer, seconds }
    }));
  };

  return (
    <div>
      <UserProfile user={appState.user} />
      <PracticeTimer timer={appState.practiceTimer} onUpdate={updateTimer} />
      <PracticeHistory history={appState.practiceHistory} />
    </div>
  );
}

// Better - separate state for different concerns
function PracticeApp() {
  const [user] = useState({ name: 'John', email: 'john@email.com' });
  const [currentPiece, setCurrentPiece] = useState(null);
  const [practiceHistory, setPracticeHistory] = useState([]);

  return (
    <div>
      <UserProfile user={user} />
      <PracticeTimer />  {/* Manages its own timer state */}
      <PracticeHistory history={practiceHistory} />
    </div>
  );
}

function PracticeTimer() {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  // Timer updates only affect this component
  useEffect(() => {
    if (!isRunning) return;

    const interval = setInterval(() => {
      setSeconds(prev => prev + 1);
    }, 1000);

    return () => clearInterval(interval);
  }, [isRunning]);

  return (
    <div className="timer">
      <div>{Math.floor(seconds / 60)}:{(seconds % 60).toString().padStart(2, '0')}</div>
      <button onClick={() => setIsRunning(!isRunning)}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
    </div>
  );
}
```
:::

By separating concerns and keeping fast-changing state localized, the improved version ensures that timer updates don't cause unnecessary re-renders of other components.

## Using React.memo for component optimization

React.memo is a higher-order component that prevents re-renders when a component's props haven't changed. This optimization is particularly useful for components that receive complex objects as props or render expensive content.

::: example
```jsx
// Without memo - re-renders every time parent re-renders
function PracticeSessionCard({ session, onEdit, onDelete }) {
  console.log('Rendering session card for:', session.title);
  
  return (
    <div className="session-card">
      <h3>{session.title}</h3>
      <p>Duration: {session.duration} minutes</p>
      <p>Date: {new Date(session.date).toLocaleDateString()}</p>
      <div className="actions">
        <button onClick={() => onEdit(session.id)}>Edit</button>
        <button onClick={() => onDelete(session.id)}>Delete</button>
      </div>
    </div>
  );
}

// With memo - only re-renders when props actually change
const OptimizedSessionCard = React.memo(function PracticeSessionCard({ 
  session, 
  onEdit, 
  onDelete 
}) {
  console.log('Rendering session card for:', session.title);
  
  return (
    <div className="session-card">
      <h3>{session.title}</h3>
      <p>Duration: {session.duration} minutes</p>
      <p>Date: {new Date(session.date).toLocaleDateString()}</p>
      <div className="actions">
        <button onClick={() => onEdit(session.id)}>Edit</button>
        <button onClick={() => onDelete(session.id)}>Delete</button>
      </div>
    </div>
  );
});

// Usage in parent component
function PracticeSessionList() {
  const [sessions, setSessions] = useState([]);
  const [filter, setFilter] = useState('');

  const editSession = useCallback((sessionId) => {
    // Edit logic here
  }, []);

  const deleteSession = useCallback((sessionId) => {
    setSessions(prev => prev.filter(s => s.id !== sessionId));
  }, []);

  const filteredSessions = sessions.filter(session =>
    session.title.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div>
      <input
        type="text"
        placeholder="Filter sessions..."
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
      />
      
      {filteredSessions.map(session => (
        <OptimizedSessionCard
          key={session.id}
          session={session}
          onEdit={editSession}
          onDelete={deleteSession}
        />
      ))}
    </div>
  );
}
```
:::

Notice how the parent component uses `useCallback` to memoize the callback functions. This prevents the memoized child components from re-rendering due to new function references being created on every render.

## Practical exercises

To solidify your understanding of state and props, work through these progressively challenging exercises. Each builds on the concepts covered in this chapter and encourages you to think about component design and data flow.

::: setup
**Exercise setup**

Create a new React project or use an existing development environment. You'll be building components that manage various types of state and communicate through props. Focus on applying the patterns and principles discussed rather than creating a polished user interface.
:::

### Exercise 1: counter variations {.unnumbered .unlisted}

Build a counter component with multiple variations to practice different state patterns:

- Create a `MultiCounter` component that manages multiple independent counters. Each counter should have its own increment, decrement, and reset functionality. Add a "Reset All" button that resets all counters to zero simultaneously.
- Consider how to structure the state (array of numbers vs. object with counter IDs) and what the performance implications might be for each approach. Implement both approaches and compare them.

### Exercise 2: form with dynamic fields {.unnumbered .unlisted}

Build a practice log form that allows users to add and remove practice techniques dynamically:

- The form should start with basic fields (piece name, duration, date) and allow users to add multiple technique entries. Each technique entry should have a name and notes field. Users should be able to remove individual techniques and reorder them.
- Focus on managing the dynamic array state properly, handling validation for dynamic fields, and ensuring the form submission includes all the dynamic data.

### Exercise 3: data fetching with error handling {.unnumbered .unlisted}

Create a component that fetches and displays practice session data with comprehensive error handling:

- Build a `PracticeSessionViewer` that fetches session data based on a session ID prop. Handle loading states, network errors, and missing data appropriately. Include retry functionality and ensure proper cleanup if the component unmounts during a fetch operation.
- Consider edge cases like what happens when the session ID changes while a request is in flight, and how to prevent race conditions between multiple requests.

### Exercise 4: component communication patterns {.unnumbered .unlisted}

Design a small application that demonstrates various communication patterns between components:

- Create a music practice tracker with these components: a piece selector, a practice timer, and a session history. The piece selector should communicate the selected piece to other components, the timer should be able to start/stop/reset based on external actions, and the session history should update when practice sessions are completed.
- Experiment with different approaches to component communication: direct prop passing, lifting state up, and using callback functions. Consider where each approach works best and what the trade-offs are.

The goal is to understand how different architectural decisions affect the complexity and maintainability of component relationships. There's no single "correct" solution. Focus on understanding the implications of your design choices.
