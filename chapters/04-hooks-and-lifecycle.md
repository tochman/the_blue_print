# Understanding Hooks and the Component Lifecycle

React hooks revolutionized how we write components by allowing function components to manage state, side effects, and lifecycle events. This chapter explores how hooks provide a more flexible and intuitive approach to component logic compared to traditional class components.

::: tip
**What you'll learn in this chapter**

- How to conceptualize component lifecycle with hooks
- Mastering `useEffect` for side effects
- Using essential hooks: `useRef`, `useMemo`, `useCallback`, and `useContext`
- Creating custom hooks for reusable logic
- Patterns for async operations and cleanup
- When and how to optimize your components
:::

## Rethinking Component Lifecycle with Hooks

In class components, lifecycle was managed with methods like `componentDidMount`, `componentDidUpdate`, and `componentWillUnmount`. Hooks, especially `useEffect`, allow you to synchronize your component with external systems and data changes in a more granular way.

::: important
**Lifecycle in the hooks world**

Function components do not have traditional lifecycle methods. Instead, use `useEffect` to synchronize with external systems and perform side effects. Multiple effects can be used to manage different concerns independently.
:::

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

This example demonstrates how multiple effects can handle different lifecycle concerns independently. Each effect is responsible for a specific piece of logic, making the component easier to reason about and maintain.

## The Mental Model of Effects

Think of effects as a way to keep your component synchronized with external systems. React checks if any dependencies for an effect have changed after each render. If so, it cleans up the previous effect and runs the new one.

::: tip
**Synchronization, not lifecycle events**

Instead of thinking "when the component mounts, fetch data," think "whenever the user ID changes, fetch data for that user." This leads to more robust components that handle data changes gracefully.
:::

## Advanced Patterns with useEffect

Complex applications often require advanced patterns for handling async operations, managing multiple data sources, and optimizing performance.

### Handling Async Operations Safely

Async operations can complete after a component unmounts or after the data they're fetching is no longer relevant. This can lead to memory leaks and race conditions. Use a cancellation flag to prevent state updates after unmounting.

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

This custom hook encapsulates async data fetching with proper cleanup and error handling.

### Managing Complex Side Effects

Some effects need to coordinate multiple async operations or maintain complex state across re-renders. Structure these effects to keep responsibilities clear and prevent bugs.

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

Each effect in this example has a specific responsibility, and they communicate through shared state for clarity and maintainability.

## Essential Built-in Hooks

Beyond `useState` and `useEffect`, React provides several other hooks for common component development problems.

### useRef for Mutable Values and DOM Access

`useRef` is used for holding mutable values that persist across renders without causing re-renders, and for accessing DOM elements directly.

::: important
**useRef vs useState**

Use `useRef` for values that change but shouldn't trigger a re-render. Use `useState` when changes should update the UI.
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

In this timer, `intervalRef` and `startTimeRef` store values without causing re-renders, while `time` is state because it affects the UI.

### useRef for DOM Manipulation

Direct DOM access is sometimes necessary for focus management, measuring dimensions, or integrating with third-party libraries.

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

This pattern is useful for managing focus, measuring elements, or scrolling to specific elements.

### useMemo and useCallback for Performance Optimization

Use `useMemo` to memoize expensive calculations and `useCallback` to prevent unnecessary function re-creation. Use them when you have expensive computations or need referential stability for child props.

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

`useMemo` prevents expensive calculations on every render, while `useCallback` ensures stable function references for child components.

::: caution
**Don't overuse memoization**

Only use `useMemo` and `useCallback` when you have real performance problems or need referential stability. Premature optimization can make code harder to read and debug.
:::

## Creating Custom Hooks

Custom hooks allow you to package complex stateful logic into reusable functions. They help you think at a higher level and keep your components declarative.

### Building Reusable Data Fetching Hooks

A well-designed data fetching hook handles loading states, errors, and cleanup automatically.

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

This custom hook encapsulates common API data fetching patterns and remains flexible through its options parameter.

### Hooks for Complex State Management

Custom hooks are ideal for managing complex state patterns that would otherwise require repetitive code.

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

This form validation hook encapsulates complex logic and is flexible for different validation requirements.

## Performance Optimization with Hooks

Understanding how hooks affect performance helps you build responsive applications. Optimize only when necessary and use the right techniques.

### Identifying Performance Bottlenecks

Use React DevTools and browser profiling to identify real performance issues, such as unnecessary re-renders or expensive calculations.

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

### Optimizing Component Updates

Use `React.memo`, `useMemo`, and `useCallback` to prevent unnecessary re-renders while keeping code clean and readable.

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

This structure ensures only components that need to update will re-render when data changes.

## Practical Exercises

These exercises will help you master hooks and lifecycle concepts through hands-on practice. Each exercise builds on the concepts covered in this chapter.

::: setup
**Exercise setup**

Create a new React project or use an existing development environment. Apply the hooks patterns and lifecycle concepts discussed in this chapter. Pay attention to performance and proper cleanup of effects.
:::

### Exercise 1: Custom Data Fetching Hook

Create a versatile `useApi` hook that handles different types of API operations (GET, POST, PUT, DELETE) with error handling, loading states, and request cancellation. Support features like retries, deduplication, and caching. Test with multiple components and handle various error scenarios.

### Exercise 2: Complex State Management Hook

Build a `usePracticeSession` hook that manages the full lifecycle of a practice session: starting, pausing, resuming, and completing sessions with automatic data persistence. Include auto-save, analytics, and integration with practice goals. Ensure state changes are synchronized with external systems.

### Exercise 3: Performance Optimization Challenge

Create a music library component that displays hundreds of pieces with filtering, sorting, and search. Optimize for smooth interactions with large datasets. Use profiling tools to identify bottlenecks and apply memoization strategies. Consider virtual scrolling and debounced search.

### Exercise 4: Lifecycle and Cleanup Patterns

Build a practice room component that integrates with external systems: a metronome, timer, and recorder. Focus on resource management and cleanup. Test scenarios where users navigate away during active sessions to ensure no resource leaks.
