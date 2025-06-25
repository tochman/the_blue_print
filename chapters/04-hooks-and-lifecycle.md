# Hooks and lifecycle

Alright, this is where React gets really interesting. Hooks were a game-changer when they were introduced in 2018-and I mean that literally. They completely transformed how we write React components, and honestly, they made React development so much more enjoyable.

Before hooks, if you wanted to use state or lifecycle methods, you had to write class components with all their boilerplate and confusing `this` binding issues. Function components were limited to displaying props-no state, no side effects, no lifecycle management. Hooks changed all that by letting you "hook into" React features from function components.

But here's the thing that took me a while to appreciate: hooks aren't just a more convenient way to write components. They fundamentally change how you think about component logic. Instead of organizing your code around rigid lifecycle phases, you organize it around what data it's synchronized with. It's a much more intuitive and powerful approach once you get the hang of it.

::: tip
**What you'll learn in this chapter**

- How to think about component lifecycle in the hooks world (spoiler: it's more flexible than you think)
- The art of `useEffect`-React's Swiss Army knife for side effects
- Essential hooks that will make your life easier: `useRef`, `useMemo`, `useCallback`, and `useContext`
- How to create custom hooks that encapsulate reusable logic beautifully
- Patterns for handling the messy realities of async operations and cleanup
- When to optimize your components (and when to resist the urge)
:::

## Understanding component lifecycle

Let's start by talking about component lifecycle, because this is where hooks really shine compared to the old class component approach.

In the class component days, lifecycle was very rigid. Your component would mount (with `componentDidMount`), update (with `componentDidUpdate`), and unmount (with `componentWillUnmount`). If you wanted to do something during these phases, you had to cram all your logic into these specific methods, even if different pieces of logic had nothing to do with each other.

Hooks flip this around completely. Instead of thinking "what should I do when the component mounts?", you think "what should I do when this specific piece of data changes?" It's much more granular and, in my experience, much easier to reason about.

::: important
**Lifecycle in the hooks world**

Function components don't have traditional lifecycle methods like `componentDidMount`. Instead, they use `useEffect` to synchronize with external systems and perform side effects. This is actually way more powerful because you can have multiple effects that each sync with different pieces of data, rather than dumping all your side effects into a few giant lifecycle methods.
:::

Let me show you what I mean. Here's a practice session tracker that demonstrates how lifecycle works with hooks:

::: example

```jsx
function PracticeSessionTracker({ sessionId }) {
  const [session, setSession] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [timer, setTimer] = useState(0);
  const [isActive, setIsActive] = useState(false);

  // Effect for fetching session data - runs when sessionId changes
  useEffect(() => {
    let cancelled = false;

    const fetchSession = async () => {
      setIsLoading(true);
      try {
        const sessionData = await PracticeSession.show(sessionId);
        if (!cancelled) {
          setSession(sessionData);
        }
      } catch (error) {
        if (!cancelled) {
          console.error('Failed to fetch session:', error);
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    };

    fetchSession();

    return () => {
      cancelled = true;
    };
  }, [sessionId]); // Only re-run when sessionId changes

  // Effect for timer - runs when isActive changes
  useEffect(() => {
    let interval = null;

    if (isActive) {
      interval = setInterval(() => {
        setTimer(prev => prev + 1);
      }, 1000);
    }

    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [isActive]); // Only re-run when isActive changes

  // Effect for auto-save - runs when timer reaches certain intervals
  useEffect(() => {
    if (timer > 0 && timer % 300 === 0) { // Auto-save every 5 minutes
      PracticeSession.update(sessionId, { 
        duration: timer,
        lastUpdate: new Date().toISOString()
      });
    }
  }, [timer, sessionId]);

  if (isLoading) return <div>Loading session...</div>;
  if (!session) return <div>Session not found</div>;

  return (
    <div className="session-tracker">
      <h2>Practicing: {session.piece}</h2>
      <div className="timer">
        {Math.floor(timer / 60)}:{(timer % 60).toString().padStart(2, '0')}
      </div>
      <button onClick={() => setIsActive(!isActive)}>
        {isActive ? 'Pause' : 'Start'}
      </button>
    </div>
  );
}
```

:::

This component demonstrates how multiple effects can handle different lifecycle concerns independently. The data fetching effect only re-runs when the session ID changes, the timer effect manages the interval based on the active state, and the auto-save effect responds to timer milestones.

### The mental model of effects {.unnumbered .unlisted}

Think of effects as a way to keep your component synchronized with external systems. Every time your component renders, React asks: "Do any of the dependencies for this effect differ from the last render?" If so, React cleans up the previous effect and runs the new one.

This mental model helps explain why effects run after every render by default and why dependency arrays are crucial for optimization. You're not thinking about mounting and unmounting-you're thinking about staying in sync with changing data.

::: tip
**Synchronization, not lifecycle events**

Instead of thinking "when the component mounts, fetch data," think "whenever the user ID changes, fetch data for that user." This shift in perspective leads to more robust components that handle data changes gracefully throughout their lifetime.
:::

## Advanced useEffect patterns

While basic `useEffect` usage covers many scenarios, complex applications require more sophisticated patterns for handling async operations, managing multiple data sources, and optimizing performance.

### Handling async operations safely {.unnumbered .unlisted}

One of the most common patterns in modern applications is fetching data based on props or state. However, async operations can complete after a component unmounts or after the data they're fetching is no longer relevant, leading to memory leaks and race conditions.

::: example

```jsx
function useAsyncOperation(asyncFunction, dependencies) {
  const [state, setState] = useState({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    let cancelled = false;

    const executeAsync = async () => {
      setState(prev => ({ ...prev, loading: true, error: null }));
      
      try {
        const result = await asyncFunction();
        
        if (!cancelled) {
          setState({
            data: result,
            loading: false,
            error: null
          });
        }
      } catch (error) {
        if (!cancelled) {
          setState({
            data: null,
            loading: false,
            error: error.message
          });
        }
      }
    };

    executeAsync();

    return () => {
      cancelled = true;
    };
  }, dependencies);

  return state;
}

// Usage in a component
function PieceDetails({ pieceId }) {
  const { data: piece, loading, error } = useAsyncOperation(
    () => MusicPiece.show(pieceId),
    [pieceId]
  );

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  if (!piece) return <div>Piece not found</div>;

  return (
    <div className="piece-details">
      <h2>{piece.title}</h2>
      <p>Composer: {piece.composer}</p>
      <p>Difficulty: {piece.difficulty}</p>
      <p>Genre: {piece.genre}</p>
    </div>
  );
}
```

:::

This custom hook encapsulates the common pattern of async data fetching with proper cleanup and error handling. The cancellation flag prevents state updates after the component unmounts or the dependencies change.

### Managing complex side effects {.unnumbered .unlisted}

Some effects need to coordinate multiple async operations or maintain complex state across re-renders. Understanding how to structure these effects prevents bugs and improves maintainability.

::: example

```jsx
function PracticeSessionManager({ userId }) {
  const [sessions, setSessions] = useState([]);
  const [activeSession, setActiveSession] = useState(null);
  const [loadingStates, setLoadingStates] = useState({
    sessions: false,
    creating: false,
    updating: false
  });

  // Effect for loading user's practice sessions
  useEffect(() => {
    let cancelled = false;

    const loadSessions = async () => {
      setLoadingStates(prev => ({ ...prev, sessions: true }));
      
      try {
        const userSessions = await PracticeSession.index({ userId });
        
        if (!cancelled) {
          setSessions(userSessions);
          
          // Set active session to the most recent incomplete one
          const incompleteSession = userSessions.find(s => !s.completed);
          if (incompleteSession) {
            setActiveSession(incompleteSession);
          }
        }
      } catch (error) {
        if (!cancelled) {
          console.error('Failed to load sessions:', error);
        }
      } finally {
        if (!cancelled) {
          setLoadingStates(prev => ({ ...prev, sessions: false }));
        }
      }
    };

    loadSessions();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  // Effect for auto-saving active session
  useEffect(() => {
    if (!activeSession) return;

    const autoSaveInterval = setInterval(async () => {
      try {
        const updatedSession = await PracticeSession.update(
          activeSession.id, 
          { lastUpdate: new Date().toISOString() }
        );
        
        setActiveSession(updatedSession);
        setSessions(prev => 
          prev.map(session => 
            session.id === activeSession.id ? updatedSession : session
          )
        );
      } catch (error) {
        console.error('Auto-save failed:', error);
      }
    }, 60000); // Auto-save every minute

    return () => {
      clearInterval(autoSaveInterval);
    };
  }, [activeSession?.id]); // Re-run when active session changes

  const createNewSession = async (sessionData) => {
    setLoadingStates(prev => ({ ...prev, creating: true }));
    
    try {
      const newSession = await PracticeSession.create({
        ...sessionData,
        userId
      });
      
      setSessions(prev => [newSession, ...prev]);
      setActiveSession(newSession);
    } catch (error) {
      console.error('Failed to create session:', error);
    } finally {
      setLoadingStates(prev => ({ ...prev, creating: false }));
    }
  };

  return {
    sessions,
    activeSession,
    loadingStates,
    createNewSession,
    setActiveSession
  };
}
```

:::

This example shows how to coordinate multiple effects that depend on each other while maintaining clear separation of concerns. Each effect has a specific responsibility, and they communicate through shared state.

## Essential built-in hooks

Beyond `useState` and `useEffect`, React provides several other hooks that solve common problems in component development. Understanding when and how to use these hooks helps you write more efficient and maintainable components.

### useRef for mutable values and DOM access {.unnumbered .unlisted}

The `useRef` hook serves two primary purposes: holding mutable values that persist across renders without triggering re-renders, and accessing DOM elements directly when needed.

::: important
**useRef vs useState**

Use `useRef` when you need to store a value that can change but shouldn't trigger a re-render. Use `useState` when changes to the value should cause the component to re-render and reflect the new state in the UI.
:::

::: example

```jsx
function PracticeTimer() {
  const [time, setTime] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const intervalRef = useRef(null);
  const startTimeRef = useRef(null);

  const startTimer = () => {
    if (!isRunning) {
      setIsRunning(true);
      startTimeRef.current = Date.now() - time * 1000;
      
      intervalRef.current = setInterval(() => {
        setTime(Math.floor((Date.now() - startTimeRef.current) / 1000));
      }, 100); // Update more frequently for smooth display
    }
  };

  const pauseTimer = () => {
    if (isRunning) {
      setIsRunning(false);
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    }
  };

  const resetTimer = () => {
    setTime(0);
    setIsRunning(false);
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
    startTimeRef.current = null;
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  return (
    <div className="practice-timer">
      <div className="time-display">
        {Math.floor(time / 60)}:{(time % 60).toString().padStart(2, '0')}
      </div>
      <div className="controls">
        {!isRunning ? (
          <button onClick={startTimer}>Start</button>
        ) : (
          <button onClick={pauseTimer}>Pause</button>
        )}
        <button onClick={resetTimer}>Reset</button>
      </div>
    </div>
  );
}
```

:::

In this timer, `intervalRef` stores the interval ID without causing re-renders, while `startTimeRef` maintains the start time for accurate time calculations. The displayed time is state because changes should trigger re-renders.

### useRef for DOM manipulation {.unnumbered .unlisted}

Sometimes you need direct access to DOM elements for focus management, measuring dimensions, or integrating with third-party libraries that expect DOM nodes.

::: example

```jsx
function AutoFocusInput({ onSubmit }) {
  const inputRef = useRef(null);
  const [value, setValue] = useState('');

  // Focus the input when component mounts
  useEffect(() => {
    if (inputRef.current) {
      inputRef.current.focus();
    }
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(value);
    setValue('');
    
    // Re-focus after submission
    if (inputRef.current) {
      inputRef.current.focus();
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        ref={inputRef}
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder="Enter piece name..."
      />
      <button type="submit">Add Piece</button>
    </form>
  );
}
```

:::

This pattern is particularly useful for managing focus in forms, measuring element dimensions, or scrolling to specific elements.

### useMemo and useCallback for performance optimization {.unnumbered .unlisted}

These hooks help optimize performance by memoizing expensive calculations (`useMemo`) and preventing unnecessary function re-creation (`useCallback`). Use them when you have expensive computations or when you need referential stability for child component props.

::: example

```jsx
function PracticeStatistics({ sessions }) {
  // Expensive calculation that only needs to re-run when sessions change
  const statistics = useMemo(() => {
    const totalTime = sessions.reduce((sum, session) => sum + session.duration, 0);
    const averageSession = totalTime / sessions.length || 0;
    const practicesByPiece = sessions.reduce((acc, session) => {
      acc[session.piece] = (acc[session.piece] || 0) + 1;
      return acc;
    }, {});
    
    const mostPracticedPiece = Object.entries(practicesByPiece)
      .sort(([,a], [,b]) => b - a)[0]?.[0] || 'None';

    return {
      totalTime,
      averageSession,
      totalSessions: sessions.length,
      mostPracticedPiece
    };
  }, [sessions]);

  // Memoized callback to prevent child re-renders
  const handleFilterChange = useCallback((filter) => {
    // Filter logic would go here
    console.log('Filter changed:', filter);
  }, []);

  return (
    <div className="practice-statistics">
      <h3>Practice Statistics</h3>
      <div className="stats-grid">
        <div className="stat">
          <span className="label">Total Practice Time</span>
          <span className="value">
            {Math.floor(statistics.totalTime / 60)}h {statistics.totalTime % 60}m
          </span>
        </div>
        <div className="stat">
          <span className="label">Average Session</span>
          <span className="value">{Math.round(statistics.averageSession)} minutes</span>
        </div>
        <div className="stat">
          <span className="label">Total Sessions</span>
          <span className="value">{statistics.totalSessions}</span>
        </div>
        <div className="stat">
          <span className="label">Most Practiced</span>
          <span className="value">{statistics.mostPracticedPiece}</span>
        </div>
      </div>
      
      <StatisticsFilter onFilterChange={handleFilterChange} />
    </div>
  );
}

// Child component that benefits from memoized callback
const StatisticsFilter = React.memo(function StatisticsFilter({ onFilterChange }) {
  const [filter, setFilter] = useState('all');

  const handleChange = (newFilter) => {
    setFilter(newFilter);
    onFilterChange(newFilter);
  };

  return (
    <div className="statistics-filter">
      <button 
        onClick={() => handleChange('all')}
        className={filter === 'all' ? 'active' : ''}
      >
        All Time
      </button>
      <button 
        onClick={() => handleChange('week')}
        className={filter === 'week' ? 'active' : ''}
      >
        This Week
      </button>
      <button 
        onClick={() => handleChange('month')}
        className={filter === 'month' ? 'active' : ''}
      >
        This Month
      </button>
    </div>
  );
});
```

:::

The `useMemo` hook prevents expensive statistics calculations on every render, while `useCallback` ensures the filter component doesn't re-render unnecessarily due to a new function reference.

::: caution
**Don't overuse memoization**

Use `useMemo` and `useCallback` when you have actual performance problems or when you need referential stability. Premature optimization can make code harder to read and debug. Profile your application to identify real bottlenecks before adding memoization.
:::

## Creating custom hooks

Here's where hooks get really exciting-and where React starts to feel like magic. Custom hooks are your way of packaging up complex stateful logic into reusable functions that you can use across different components. They're just functions that use other hooks, but the abstraction they provide is incredibly powerful.

I remember the first time I extracted a complex data fetching pattern into a custom hook. I had this gnarly component with loading states, error handling, retry logic, and cleanup code all tangled together. After extracting it into a custom hook, the component became crystal clear, and I could reuse the same logic in five other places. It was one of those moments where you realize the real power of React's design.

The beauty of custom hooks is that they let you think at a higher level. Instead of managing individual pieces of state and effects, you can create abstractions that encapsulate entire behaviors. Need to fetch data? Use `useApiData`. Need to handle form state? Use `useForm`. Need to manage a timer? Use `useTimer`. Your components become declarative descriptions of what they do, not how they do it.

### Building reusable data fetching hooks {.unnumbered .unlisted}

Data fetching is a common pattern that benefits from extraction into custom hooks. A well-designed data fetching hook handles loading states, errors, and cleanup automatically.

::: example

```jsx
function useApiData(url, options = {}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const { 
    dependencies = [], 
    immediate = true,
    onSuccess,
    onError 
  } = options;

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const result = await response.json();
      setData(result);
      
      if (onSuccess) {
        onSuccess(result);
      }
    } catch (err) {
      setError(err.message);
      
      if (onError) {
        onError(err);
      }
    } finally {
      setLoading(false);
    }
  }, [url, onSuccess, onError]);

  useEffect(() => {
    if (immediate) {
      fetchData();
    }
  }, [fetchData, immediate, ...dependencies]);

  const refetch = useCallback(() => {
    fetchData();
  }, [fetchData]);

  return {
    data,
    loading,
    error,
    refetch
  };
}

// Usage in components
function PieceLibrary() {
  const { 
    data: pieces, 
    loading, 
    error, 
    refetch 
  } = useApiData('/api/pieces', {
    onSuccess: (data) => console.log(`Loaded ${data.length} pieces`),
    onError: (error) => console.error('Failed to load pieces:', error)
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} onRetry={refetch} />;

  return (
    <div className="piece-library">
      <h2>Music Library</h2>
      <button onClick={refetch}>Refresh</button>
      <div className="pieces-grid">
        {pieces?.map(piece => (
          <PieceCard key={piece.id} piece={piece} />
        ))}
      </div>
    </div>
  );
}

function PracticeHistory({ userId }) {
  const { 
    data: sessions, 
    loading, 
    error 
  } = useApiData(`/api/users/${userId}/sessions`, {
    dependencies: [userId],
    immediate: !!userId // Only fetch if userId is provided
  });

  // Component implementation...
}
```

:::

This custom hook encapsulates all the common patterns for API data fetching while remaining flexible enough to handle different use cases through its options parameter.

### Hooks for complex state management {.unnumbered .unlisted}

Custom hooks excel at managing complex state patterns that would otherwise require repetitive code across multiple components.

::: example

```jsx
function useFormValidation(initialValues, validationRules) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validateField = useCallback((name, value) => {
    const rules = validationRules[name];
    if (!rules) return null;

    for (const rule of rules) {
      const error = rule(value, values);
      if (error) return error;
    }
    return null;
  }, [validationRules, values]);

  const updateField = useCallback((name, value) => {
    setValues(prev => ({ ...prev, [name]: value }));
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: null }));
    }
  }, [errors]);

  const blurField = useCallback((name) => {
    setTouched(prev => ({ ...prev, [name]: true }));
    
    const error = validateField(name, values[name]);
    if (error) {
      setErrors(prev => ({ ...prev, [name]: error }));
    }
  }, [validateField, values]);

  const validateForm = useCallback(() => {
    const newErrors = {};
    let hasErrors = false;

    Object.keys(validationRules).forEach(name => {
      const error = validateField(name, values[name]);
      if (error) {
        newErrors[name] = error;
        hasErrors = true;
      }
    });

    setErrors(newErrors);
    setTouched(Object.keys(validationRules).reduce(
      (acc, key) => ({ ...acc, [key]: true }), 
      {}
    ));

    return !hasErrors;
  }, [validateField, validationRules, values]);

  const handleSubmit = useCallback(async (onSubmit) => {
    if (isSubmitting) return;

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(values);
    } catch (error) {
      setErrors({ submit: error.message });
    } finally {
      setIsSubmitting(false);
    }
  }, [isSubmitting, validateForm, values]);

  const reset = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  return {
    values,
    errors,
    touched,
    isSubmitting,
    updateField,
    blurField,
    handleSubmit,
    reset,
    isValid: Object.keys(errors).length === 0
  };
}

// Validation rules
const pieceValidationRules = {
  title: [
    (value) => !value?.trim() ? 'Title is required' : null,
    (value) => value?.length < 2 ? 'Title must be at least 2 characters' : null
  ],
  composer: [
    (value) => !value?.trim() ? 'Composer is required' : null
  ],
  difficulty: [
    (value) => !['beginner', 'intermediate', 'advanced'].includes(value) 
      ? 'Please select a valid difficulty' : null
  ]
};

// Usage in a component
function AddPieceForm({ onSubmit }) {
  const form = useFormValidation(
    { title: '', composer: '', difficulty: 'intermediate' },
    pieceValidationRules
  );

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      form.handleSubmit(onSubmit);
    }}>
      <div className="form-field">
        <input
          type="text"
          placeholder="Piece title"
          value={form.values.title}
          onChange={(e) => form.updateField('title', e.target.value)}
          onBlur={() => form.blurField('title')}
        />
        {form.touched.title && form.errors.title && (
          <span className="error">{form.errors.title}</span>
        )}
      </div>

      <div className="form-field">
        <input
          type="text"
          placeholder="Composer"
          value={form.values.composer}
          onChange={(e) => form.updateField('composer', e.target.value)}
          onBlur={() => form.blurField('composer')}
        />
        {form.touched.composer && form.errors.composer && (
          <span className="error">{form.errors.composer}</span>
        )}
      </div>

      <div className="form-field">
        <select
          value={form.values.difficulty}
          onChange={(e) => form.updateField('difficulty', e.target.value)}
          onBlur={() => form.blurField('difficulty')}
        >
          <option value="beginner">Beginner</option>
          <option value="intermediate">Intermediate</option>
          <option value="advanced">Advanced</option>
        </select>
        {form.touched.difficulty && form.errors.difficulty && (
          <span className="error">{form.errors.difficulty}</span>
        )}
      </div>

      {form.errors.submit && (
        <div className="error">{form.errors.submit}</div>
      )}

      <div className="form-actions">
        <button type="button" onClick={form.reset}>
          Reset
        </button>
        <button type="submit" disabled={form.isSubmitting || !form.isValid}>
          {form.isSubmitting ? 'Adding...' : 'Add Piece'}
        </button>
      </div>
    </form>
  );
}
```

:::

This form validation hook encapsulates complex form logic while remaining flexible enough to handle different validation requirements across different forms.

## Performance optimization with hooks

Understanding how hooks affect performance helps you build applications that remain responsive as they grow in complexity. The key is knowing when optimization is necessary and which techniques to apply.

### Identifying performance bottlenecks {.unnumbered .unlisted}

Before optimizing, identify actual performance problems using React's development tools and browser profiling. Common performance issues include unnecessary re-renders, expensive calculations on every render, and memory leaks from improperly cleaned up effects.

::: example

```jsx
// Problematic - expensive calculation on every render
function ExpensivePracticeAnalysis({ sessions }) {
  // This runs on every render!
  const analysis = sessions.reduce((acc, session) => {
    // Complex analysis logic...
    return acc;
  }, {});

  return <div>{/* Render analysis */}</div>;
}

// Better - memoized calculation
function OptimizedPracticeAnalysis({ sessions }) {
  const analysis = useMemo(() => {
    return sessions.reduce((acc, session) => {
      // Complex analysis logic...
      return acc;
    }, {});
  }, [sessions]); // Only recalculate when sessions change

  return <div>{/* Render analysis */}</div>;
}

// Custom hook for complex analysis
function usePracticeAnalysis(sessions) {
  return useMemo(() => {
    const totalTime = sessions.reduce((sum, session) => sum + session.duration, 0);
    const averageDuration = totalTime / sessions.length || 0;
    
    const progressByPiece = sessions.reduce((acc, session) => {
      if (!acc[session.piece]) {
        acc[session.piece] = {
          totalTime: 0,
          sessionCount: 0,
          averageRating: 0
        };
      }
      
      acc[session.piece].totalTime += session.duration;
      acc[session.piece].sessionCount += 1;
      acc[session.piece].averageRating = 
        (acc[session.piece].averageRating + (session.rating || 0)) / 
        acc[session.piece].sessionCount;
      
      return acc;
    }, {});

    return {
      totalTime,
      averageDuration,
      progressByPiece,
      totalSessions: sessions.length
    };
  }, [sessions]);
}
```

:::

### Optimizing component updates {.unnumbered .unlisted}

Use React.memo, useMemo, and useCallback strategically to prevent unnecessary re-renders while maintaining clean, readable code.

::: example

```jsx
// Parent component that manages sessions
function PracticeTracker() {
  const [sessions, setSessions] = useState([]);
  const [filter, setFilter] = useState('all');
  const [sortBy, setSortBy] = useState('date');

  // Memoized filtered and sorted sessions
  const processedSessions = useMemo(() => {
    let filtered = sessions;
    
    if (filter !== 'all') {
      filtered = sessions.filter(session => session.status === filter);
    }
    
    return filtered.sort((a, b) => {
      if (sortBy === 'date') {
        return new Date(b.date) - new Date(a.date);
      }
      if (sortBy === 'duration') {
        return b.duration - a.duration;
      }
      return a.piece.localeCompare(b.piece);
    });
  }, [sessions, filter, sortBy]);

  // Memoized callbacks to prevent child re-renders
  const handleSessionUpdate = useCallback((sessionId, updates) => {
    setSessions(prev => 
      prev.map(session => 
        session.id === sessionId ? { ...session, ...updates } : session
      )
    );
  }, []);

  const handleSessionDelete = useCallback((sessionId) => {
    setSessions(prev => prev.filter(session => session.id !== sessionId));
  }, []);

  return (
    <div className="practice-tracker">
      <PracticeControls 
        filter={filter}
        sortBy={sortBy}
        onFilterChange={setFilter}
        onSortChange={setSortBy}
      />
      
      <SessionList
        sessions={processedSessions}
        onSessionUpdate={handleSessionUpdate}
        onSessionDelete={handleSessionDelete}
      />
    </div>
  );
}

// Optimized session list that only re-renders when sessions change
const SessionList = React.memo(function SessionList({ 
  sessions, 
  onSessionUpdate, 
  onSessionDelete 
}) {
  return (
    <div className="session-list">
      {sessions.map(session => (
        <SessionItem
          key={session.id}
          session={session}
          onUpdate={onSessionUpdate}
          onDelete={onSessionDelete}
        />
      ))}
    </div>
  );
});

// Individual session item with its own optimization
const SessionItem = React.memo(function SessionItem({ 
  session, 
  onUpdate, 
  onDelete 
}) {
  const handleRatingChange = useCallback((newRating) => {
    onUpdate(session.id, { rating: newRating });
  }, [session.id, onUpdate]);

  const handleDelete = useCallback(() => {
    onDelete(session.id);
  }, [session.id, onDelete]);

  return (
    <div className="session-item">
      <h3>{session.piece}</h3>
      <p>Duration: {session.duration} minutes</p>
      <div className="rating">
        <span>Rating: </span>
        {[1, 2, 3, 4, 5].map(rating => (
          <button
            key={rating}
            onClick={() => handleRatingChange(rating)}
            className={session.rating >= rating ? 'active' : ''}
          >
            *
          </button>
        ))}
      </div>
      <button onClick={handleDelete}>Delete</button>
    </div>
  );
});
```

:::

This structure ensures that only the components that actually need to update will re-render when the data changes.

## Practical exercises

These exercises will help you master hooks and lifecycle concepts through hands-on practice. Each exercise builds on the concepts covered in this chapter.

::: setup

**Exercise setup**

Create a new React project or use an existing development environment. Focus on applying the hooks patterns and lifecycle concepts discussed in this chapter. Pay attention to performance implications and proper cleanup of effects.

:::

### Exercise 1: Custom data fetching hook {.unnumbered .unlisted}

Create a versatile `useApi` hook that handles different types of API operations (GET, POST, PUT, DELETE) with proper error handling, loading states, and request cancellation.

Your hook should support features like automatic retries, request deduplication, and caching. Test it with multiple components that fetch different types of data and handle various error scenarios.

Consider edge cases like what happens when the same request is made multiple times quickly, how to handle network failures, and how to prevent memory leaks when components unmount during requests.

### Exercise 2: Complex state management hook {.unnumbered .unlisted}

Build a `usePracticeSession` hook that manages the full lifecycle of a practice session: starting, pausing, resuming, and completing sessions with automatic data persistence.

Include features like auto-save functionality, session analytics calculation, and integration with a practice goals system. The hook should handle complex state transitions and provide a clean interface for components to interact with.

Focus on managing multiple interdependent pieces of state and ensuring that state changes are properly synchronized with external systems.

### Exercise 3: Performance optimization challenge {.unnumbered .unlisted}

Create a music library component that displays hundreds of pieces with filtering, sorting, and search capabilities. Implement proper performance optimizations to ensure smooth interactions even with large datasets.

Use React DevTools Profiler to identify performance bottlenecks and apply appropriate optimization techniques. Experiment with different memoization strategies and measure their impact on performance.

Consider implementing features like virtual scrolling for large lists and debounced search to reduce unnecessary computations.

### Exercise 4: Lifecycle and cleanup patterns {.unnumbered .unlisted}

Build a practice room component that integrates with external systems: a metronome that plays audio, a timer that shows elapsed time, and a recorder that captures practice notes.

Focus on proper resource management: cleaning up audio resources, managing timer intervals, and handling component unmounting gracefully. Test scenarios where users navigate away during active practice sessions.

The goal is to understand how to manage complex side effects and ensure that your components don't leak resources or cause errors when they're no longer needed.
