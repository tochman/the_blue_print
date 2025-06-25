# Render Props and Function-as-Children Patterns

Render props are a powerful pattern for sharing logic between components while giving consumers complete control over rendering. Instead of passing data or configuration through props, you pass a function that returns JSX. This approach separates logic from presentation, making your components more reusable and flexible.

The term "render prop" refers to a prop whose value is a function that returns a React element. The component with the render prop calls this function instead of implementing its own render logic, giving the consumer complete control over what gets rendered.

::: important
**Logic vs. presentation separation**

Render props excel at separating "what to do" (the logic) from "how to display it" (the presentation). This separation makes it possible to reuse complex logic across different visual representations while keeping the logic component focused solely on behavior.
:::

Consider a component that manages practice session data loading and error handling:

::: example
```jsx
// Traditional approach - tightly coupled logic and presentation
function PracticeSessionList({ userId }) {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchSessions(userId)
      .then(setSessions)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading sessions...</div>;
  if (error) return <div>Error: {error.message}</div>;
  
  return (
    <div className="session-list">
      {sessions.map(session => (
        <div key={session.id} className="session-item">
          <h3>{session.piece}</h3>
          <p>Duration: {session.duration} minutes</p>
        </div>
      ))}
    </div>
  );
}

// Render props approach - separated logic and presentation
function SessionDataProvider({ userId, children }) {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchSessions(userId)
      .then(setSessions)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  const refetch = () => {
    setLoading(true);
    setError(null);
    fetchSessions(userId)
      .then(setSessions)
      .catch(setError)
      .finally(() => setLoading(false));
  };

  return children({ sessions, loading, error, refetch });
}

// Now the presentation can vary while reusing the same logic
function SessionListView({ userId }) {
  return (
    <SessionDataProvider userId={userId}>
      {({ sessions, loading, error, refetch }) => {
        if (loading) return <div>Loading sessions...</div>;
        if (error) return (
          <div>
            <p>Error: {error.message}</p>
            <button onClick={refetch}>Retry</button>
          </div>
        );
        
        return (
          <div className="session-list">
            {sessions.map(session => (
              <div key={session.id} className="session-item">
                <h3>{session.piece}</h3>
                <p>Duration: {session.duration} minutes</p>
              </div>
            ))}
          </div>
        );
      }}
    </SessionDataProvider>
  );
}

function SessionGridView({ userId }) {
  return (
    <SessionDataProvider userId={userId}>
      {({ sessions, loading, error }) => {
        if (loading) return <div className="grid-loading">Loading...</div>;
        if (error) return <div className="grid-error">Failed to load sessions</div>;
        
        return (
          <div className="session-grid">
            {sessions.map(session => (
              <div key={session.id} className="session-card">
                <h4>{session.piece}</h4>
                <span className="duration">{session.duration}m</span>
              </div>
            ))}
          </div>
        );
      }}
    </SessionDataProvider>
  );
}
```
:::

The render props pattern allows the same data fetching logic to power completely different presentations. The `SessionDataProvider` component focuses solely on managing the data and state, while the consumer components control how that data is displayed.

## Function-as-Children Pattern

The function-as-children pattern is a specific variant of render props where the render function is passed as the `children` prop. This pattern often feels more natural and readable, especially when the render prop is the only or primary prop.

::: example
```jsx
function PracticeTimer({ children }) {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    let interval = null;
    if (isRunning) {
      interval = setInterval(() => {
        setSeconds(prev => prev + 1);
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

  return children({ 
    seconds, 
    isRunning, 
    start, 
    pause, 
    reset,
    formattedTime: `${Math.floor(seconds / 60)}:${(seconds % 60).toString().padStart(2, '0')}`
  });
}

// Different implementations using the same timer logic
function SimpleTimer() {
  return (
    <PracticeTimer>
      {({ formattedTime }) => (
        <span className="simple-timer">{formattedTime}</span>
      )}
    </PracticeTimer>
  );
}

function DetailedTimer() {
  return (
    <PracticeTimer>
      {({ formattedTime, isRunning, start, pause, reset }) => (
        <div className="detailed-timer">
          <h4>Practice Session Timer</h4>
          <p className="time-display">{formattedTime}</p>
          <div className="timer-controls">
            {!isRunning ? (
              <button onClick={start}>Start</button>
            ) : (
              <button onClick={pause}>Pause</button>
            )}
            <button onClick={reset}>Reset</button>
          </div>
        </div>
      )}
    </PracticeTimer>
  );
}

function CompactTimer() {
  return (
    <PracticeTimer>
      {({ seconds, isRunning, start, pause }) => (
        <div className="compact-timer">
          <span>{seconds}s</span>
          <button onClick={isRunning ? pause : start}>
            {isRunning ? '⏸' : '▶'}
          </button>
        </div>
      )}
    </PracticeTimer>
  );
}
```
:::

This pattern is particularly powerful because the timer logic is completely reusable across different contexts, while each implementation can render the timer information in the way that best fits its specific use case.

## Advanced Render Props Patterns

Render props can be enhanced with additional patterns to handle more complex scenarios:

::: example
```jsx
// Render props with multiple render functions
function PracticeSessionManager({ 
  children, 
  onError, 
  onSuccess,
  renderLoading,
  renderError 
}) {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchSessions()
      .then(data => {
        setSessions(data);
        onSuccess?.(data);
      })
      .catch(err => {
        setError(err);
        onError?.(err);
      })
      .finally(() => setLoading(false));
  }, [onError, onSuccess]);

  if (loading && renderLoading) {
    return renderLoading();
  }

  if (error && renderError) {
    return renderError(error);
  }

  return children({ sessions, loading, error });
}

// Usage with destructured render props
function SessionManagerApp() {
  return (
    <PracticeSessionManager
      renderLoading={() => <div className="custom-loading">Loading sessions...</div>}
      renderError={(error) => <div className="custom-error">Failed: {error.message}</div>}
      onSuccess={(sessions) => console.log(`Loaded ${sessions.length} sessions`)}
    >
      {({ sessions }) => (
        <div className="session-app">
          <h2>Your Practice Sessions</h2>
          {sessions.map(session => (
            <SessionCard key={session.id} session={session} />
          ))}
        </div>
      )}
    </PracticeSessionManager>
  );
}
```
:::

## When to Choose Render Props

Render props are ideal when you need to:

- Share stateful logic between components with different presentations
- Build reusable data fetching or state management components
- Create components that adapt their rendering based on dynamic conditions
- Separate concerns between logic and presentation layers

::: caution
**Render props vs. custom hooks**

Modern React development often favors custom hooks over render props for sharing logic. Hooks generally provide a cleaner API and better composition. However, render props are still valuable when you need to share JSX-generating logic or when building component libraries that need to work with older React versions.
:::

The choice between render props and other patterns depends on your specific needs:

- **Custom hooks**: Better for sharing stateful logic that doesn't involve JSX generation
- **Compound components**: Better for components with multiple related parts
- **Render props**: Better when you need complete control over rendering and want to separate logic from presentation

Both compound components and render props represent powerful tools for building flexible, reusable React components. Understanding when and how to apply each pattern helps you create more maintainable and extensible applications.
