# Advanced patterns

I'll be honest with you-this is where things get really interesting, but also a bit challenging. If you've been following along through the previous chapters, you've built a solid foundation with components, state, and hooks. Now we're going to take a big step forward into the patterns that separate good React developers from great ones.

Fair warning: this is probably the most complex chapter in the book. We're going to cover some heavy topics, and there's going to be a lot of code. But here's the thing-these patterns are what you'll use to build truly sophisticated applications. The kind that scale gracefully, handle complexity elegantly, and make other developers say "how did they do that?"

I remember when I first encountered compound components and render props. My initial reaction was "this seems overly complicated." But once I saw how they solved real problems I was struggling with-creating flexible APIs, sharing logic without duplication, building truly reusable components-everything clicked. These aren't academic exercises; they're practical solutions to problems you will face.

::: tip
**Take your time with this chapter**

Don't feel like you need to absorb everything at once. These are advanced patterns that even experienced developers sometimes struggle with. Read through once to get the big picture, then come back to implement the exercises. Most importantly, try to see how each pattern solves problems you've actually encountered in your own projects.
:::

As your React applications grow beyond simple todo lists and basic forms, you'll hit walls that basic component composition just can't handle. Need to share complex logic between components? There's a pattern for that. Want to create components that are flexible enough for a design system but simple enough for junior developers? We've got you covered. Building an app that needs to coordinate complex state across many components? Let's talk about provider patterns.

## Compound components: Building flexible APIs

Let me start with one of my favorite patterns: compound components. I love this pattern because it solves a problem we've all faced-how do you make a component that's both powerful and easy to use?

You know that moment when you're building a component and you start adding prop after prop to control every little detail? `showHeader`, `headerAlignment`, `showControls`, `controlsPosition`, `allowMinimize`... Before you know it, your component has 20 props and the API is a nightmare. I've been there, and it's not pretty.

Compound components flip this on its head. Instead of trying to predict every possible configuration through props, you let the user compose the component exactly how they need it. Think of it like giving someone LEGO blocks instead of a pre-built house-much more flexible, and often more intuitive.

::: important
**The compound component advantage**

I like to think of compound components as having a conversation with your JSX. Instead of saying "render a header with these specific options," you're saying "here's a header, here's some content, arrange them however makes sense." The structure of your JSX becomes a blueprint for what you want to build.
:::

```

Consider how a practice session player might work with compound components:

::: example

```jsx
// Traditional prop-heavy approach (harder to customize)
<SessionPlayer
  session={session}
  showControls={true}
  showProgress={true}
  showNotes={false}
  controlPosition="bottom"
  progressStyle="bar"
  onPlay={handlePlay}
  onPause={handlePause}
/>

// Compound component approach (more flexible and readable)
<SessionPlayer session={session}>
  <SessionPlayer.Progress />
  <SessionPlayer.Content />
  <SessionPlayer.Notes />
  <SessionPlayer.Controls>
    <SessionPlayer.PlayButton />
    <SessionPlayer.PauseButton />
    <SessionPlayer.SpeedControl />
  </SessionPlayer.Controls>
</SessionPlayer>
```

:::

The compound component version is more verbose but provides much greater flexibility. Users can rearrange components, omit pieces they don't need, and the intent is clear from the JSX structure.

### Implementing compound components with context {.unnumbered .unlisted}

The most robust way to implement compound components is using React Context to share state between the parent and child components. This allows the child components to access shared state without prop drilling.

::: example

```jsx
import React, { createContext, useContext, useState, useCallback } from 'react';

// Create context for sharing state between compound components
const SessionPlayerContext = createContext();

function useSessionPlayer() {
  const context = useContext(SessionPlayerContext);
  if (!context) {
    throw new Error('SessionPlayer compound components must be used within SessionPlayer');
  }
  return context;
}

// Main compound component that provides state and context
function SessionPlayer({ session, children, onSessionUpdate }) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [playbackSpeed, setPlaybackSpeed] = useState(1.0);
  const [notes, setNotes] = useState(session?.notes || '');

  const play = useCallback(() => {
    setIsPlaying(true);
    // Actual play logic would go here
  }, []);

  const pause = useCallback(() => {
    setIsPlaying(false);
    // Actual pause logic would go here
  }, []);

  const updateNotes = useCallback((newNotes) => {
    setNotes(newNotes);
    if (onSessionUpdate) {
      onSessionUpdate({ ...session, notes: newNotes });
    }
  }, [session, onSessionUpdate]);

  const contextValue = {
    session,
    isPlaying,
    currentTime,
    playbackSpeed,
    notes,
    play,
    pause,
    setCurrentTime,
    setPlaybackSpeed,
    updateNotes
  };

  return (
    <SessionPlayerContext.Provider value={contextValue}>
      <div className="session-player">
        {children}
      </div>
    </SessionPlayerContext.Provider>
  );
}

// Individual compound components
SessionPlayer.Progress = function Progress() {
  const { session, currentTime } = useSessionPlayer();
  const duration = session?.duration || 0;
  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <div className="session-progress">
      <div className="progress-bar">
        <div 
          className="progress-fill" 
          style={{ width: `${progress}%` }}
        />
      </div>
      <div className="time-display">
        {formatTime(currentTime)} / {formatTime(duration)}
      </div>
    </div>
  );
};

SessionPlayer.Content = function Content() {
  const { session } = useSessionPlayer();

  return (
    <div className="session-content">
      <h3>{session?.piece}</h3>
      <p className="composer">{session?.composer}</p>
      <p className="date">
        Recorded: {new Date(session?.date).toLocaleDateString()}
      </p>
    </div>
  );
};

SessionPlayer.Controls = function Controls({ children }) {
  return (
    <div className="session-controls">
      {children}
    </div>
  );
};

SessionPlayer.PlayButton = function PlayButton() {
  const { isPlaying, play } = useSessionPlayer();

  return (
    <button 
      onClick={play} 
      disabled={isPlaying}
      className="control-button play-button"
    >
      [Play] Play
    </button>
  );
};

SessionPlayer.PauseButton = function PauseButton() {
  const { isPlaying, pause } = useSessionPlayer();

  return (
    <button 
      onClick={pause} 
      disabled={!isPlaying}
      className="control-button pause-button"
    >
      ⏸️ Pause
    </button>
  );
};

SessionPlayer.SpeedControl = function SpeedControl() {
  const { playbackSpeed, setPlaybackSpeed } = useSessionPlayer();

  return (
    <div className="speed-control">
      <label htmlFor="speed">Speed:</label>
      <select 
        id="speed"
        value={playbackSpeed} 
        onChange={(e) => setPlaybackSpeed(parseFloat(e.target.value))}
      >
        <option value={0.5}>0.5x</option>
        <option value={0.75}>0.75x</option>
        <option value={1.0}>1.0x</option>
        <option value={1.25}>1.25x</option>
        <option value={1.5}>1.5x</option>
      </select>
    </div>
  );
};

SessionPlayer.Notes = function Notes() {
  const { notes, updateNotes } = useSessionPlayer();
  const [isEditing, setIsEditing] = useState(false);
  const [editedNotes, setEditedNotes] = useState(notes);

  const handleSave = () => {
    updateNotes(editedNotes);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setEditedNotes(notes);
    setIsEditing(false);
  };

  return (
    <div className="session-notes">
      <h4>Practice Notes</h4>
      {isEditing ? (
        <div className="notes-editor">
          <textarea
            value={editedNotes}
            onChange={(e) => setEditedNotes(e.target.value)}
            rows={4}
          />
          <div className="notes-actions">
            <button onClick={handleSave}>Save</button>
            <button onClick={handleCancel}>Cancel</button>
          </div>
        </div>
      ) : (
        <div className="notes-display">
          <p>{notes || 'No notes yet...'}</p>
          <button onClick={() => setIsEditing(true)}>Edit Notes</button>
        </div>
      )}
    </div>
  );
};

// Utility function
function formatTime(seconds) {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}
```

:::

This implementation demonstrates several key aspects of compound components:

1. **Shared context**: All child components can access the same state through the context
2. **Flexible composition**: Users can arrange components in any order they want
3. **Clean APIs**: Each component has a focused responsibility
4. **Type safety**: The custom hook ensures components are used within the correct context

### When to use compound components {.unnumbered .unlisted}

Compound components work best for UI elements that have multiple related parts that users might want to customize or rearrange. They're particularly effective for:

- Modal dialogs with headers, content, and footers
- Form components with labels, inputs, and validation messages
- Media players with controls, progress bars, and metadata
- Card components with images, titles, descriptions, and actions
- Navigation components with various menu items and sections

::: tip
**Compound components vs. regular composition**

Use compound components when the child components need to share state and behavior. If the components are truly independent, regular composition with separate components might be simpler and more appropriate.
:::

## Render props and function-as-children patterns

Here's another pattern that might make your brain hurt a little at first: render props. I remember staring at my first render prop component thinking "wait, you're passing a *function* that returns JSX as a *prop*?" It felt backwards and overcomplicated.

But once you see it in action, it's actually quite elegant. Render props let you share logic between components while keeping complete control over what gets rendered. Think of it as lending someone your car engine while they provide their own car body-you handle the complex machinery, they handle the aesthetics.

The beauty of render props is in the separation of concerns. Your component handles all the tricky state management, data fetching, or business logic, while the consuming component decides exactly how that information should be displayed. No more guessing what props to expose or trying to make your component flexible enough for every possible use case.

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
    // Fetch logic...
  }, [userId]);

  if (loading) return <div>Loading sessions...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="session-list">
      {sessions.map(session => (
        <div key={session.id} className="session-item">
          <h3>{session.piece}</h3>
          <p>{session.duration} minutes</p>
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
    let cancelled = false;

    const fetchSessions = async () => {
      setLoading(true);
      setError(null);

      try {
        const data = await PracticeSessionAPI.getByUser(userId);
        if (!cancelled) {
          setSessions(data);
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

    if (userId) {
      fetchSessions();
    }

    return () => {
      cancelled = true;
    };
  }, [userId]);

  const refetch = useCallback(async () => {
    // Refetch logic similar to above
  }, [userId]);

  return children({ sessions, loading, error, refetch });
}

// Now the presentation can vary while reusing the same logic
function SessionListView({ userId }) {
  return (
    <SessionDataProvider userId={userId}>
      {({ sessions, loading, error, refetch }) => {
        if (loading) return <LoadingSpinner />;
        if (error) return (
          <ErrorDisplay 
            message={error} 
            onRetry={refetch} 
          />
        );

        return (
          <div className="session-list">
            {sessions.map(session => (
              <SessionCard key={session.id} session={session} />
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
        if (loading) return <GridSkeleton />;
        if (error) return <ErrorBanner message={error} />;

        return (
          <div className="session-grid">
            {sessions.map(session => (
              <SessionTile key={session.id} session={session} />
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

### Function-as-children pattern {.unnumbered .unlisted}

The function-as-children pattern is a specific variant of render props where the render function is passed as the `children` prop. This pattern often feels more natural and readable, especially when the render prop is the only or primary prop.

::: example

```jsx
function PracticeTimer({ children }) {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const [startTime, setStartTime] = useState(null);

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

  const start = useCallback(() => {
    setIsRunning(true);
    setStartTime(Date.now());
  }, []);

  const pause = useCallback(() => {
    setIsRunning(false);
  }, []);

  const reset = useCallback(() => {
    setSeconds(0);
    setIsRunning(false);
    setStartTime(null);
  }, []);

  const formatTime = useCallback((totalSeconds) => {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }, []);

  return children({
    seconds,
    isRunning,
    formattedTime: formatTime(seconds),
    start,
    pause,
    reset,
    startTime
  });
}

// Different implementations using the same timer logic
function SimpleTimer() {
  return (
    <PracticeTimer>
      {({ formattedTime, isRunning, start, pause, reset }) => (
        <div className="simple-timer">
          <div className="time-display">{formattedTime}</div>
          <div className="controls">
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

function DetailedTimer() {
  return (
    <PracticeTimer>
      {({ seconds, formattedTime, isRunning, start, pause, reset, startTime }) => (
        <div className="detailed-timer">
          <h3>Practice Session Timer</h3>
          <div className="timer-display">
            <div className="main-time">{formattedTime}</div>
            <div className="session-info">
              <p>Status: {isRunning ? 'Recording' : 'Paused'}</p>
              {startTime && (
                <p>Started: {new Date(startTime).toLocaleTimeString()}</p>
              )}
              <p>Total seconds: {seconds}</p>
            </div>
          </div>
          <div className="timer-controls">
            <button 
              onClick={start} 
              disabled={isRunning}
              className="start-btn"
            >
              [Music] Start Practice
            </button>
            <button 
              onClick={pause} 
              disabled={!isRunning}
              className="pause-btn"
            >
              ⏸️ Pause
            </button>
            <button onClick={reset} className="reset-btn">
              [Reset] Reset
            </button>
          </div>
        </div>
      )}
    </PracticeTimer>
  );
}

function CompactTimer() {
  return (
    <PracticeTimer>
      {({ formattedTime, isRunning, start, pause }) => (
        <span className="compact-timer">
          {formattedTime}
          <button onClick={isRunning ? pause : start}>
            {isRunning ? '[Pause]' : '[Play]'}
          </button>
        </span>
      )}
    </PracticeTimer>
  );
}
```

:::

This pattern is particularly powerful because the timer logic is completely reusable across different contexts, while each implementation can render the timer information in the way that best fits its specific use case.

### Advanced render props patterns {.unnumbered .unlisted}

Render props can be enhanced with additional patterns to handle more complex scenarios:

::: example

```jsx
// Render props with multiple render functions
function PracticeSessionManager({ children, onError, onSuccess }) {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const createSession = useCallback(async (sessionData) => {
    setLoading(true);
    setError(null);

    try {
      const newSession = await PracticeSessionAPI.create(sessionData);
      setSessions(prev => [newSession, ...prev]);
      if (onSuccess) onSuccess(newSession);
      return newSession;
    } catch (err) {
      setError(err.message);
      if (onError) onError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [onSuccess, onError]);

  const updateSession = useCallback(async (sessionId, updates) => {
    try {
      const updatedSession = await PracticeSessionAPI.update(sessionId, updates);
      setSessions(prev => 
        prev.map(session => 
          session.id === sessionId ? updatedSession : session
        )
      );
      return updatedSession;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, []);

  const deleteSession = useCallback(async (sessionId) => {
    try {
      await PracticeSessionAPI.delete(sessionId);
      setSessions(prev => prev.filter(session => session.id !== sessionId));
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, []);

  return children({
    sessions,
    loading,
    error,
    actions: {
      create: createSession,
      update: updateSession,
      delete: deleteSession,
      clearError: () => setError(null)
    }
  });
}

// Usage with destructured render props
function SessionManagerApp() {
  return (
    <PracticeSessionManager>
      {({ sessions, loading, error, actions }) => (
        <div className="session-manager">
          {error && (
            <ErrorAlert 
              message={error} 
              onDismiss={actions.clearError} 
            />
          )}
          
          <CreateSessionForm 
            onSubmit={actions.create}
            loading={loading}
          />
          
          <SessionList
            sessions={sessions}
            onUpdate={actions.update}
            onDelete={actions.delete}
          />
        </div>
      )}
    </PracticeSessionManager>
  );
}
```

:::

### When to choose render props {.unnumbered .unlisted}

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

## Higher-order components: Enhancement and composition

Let's talk about Higher-Order Components, or HOCs-one of React's "classic" patterns that you might encounter in older codebases. I have a bit of a love-hate relationship with HOCs. They're intellectually satisfying (functions that take components and return enhanced components-very functional programming!), but they can also make your component tree look like a Christmas decoration gone wrong.

Here's the thing: if you're starting a new React project today, you probably won't write many HOCs. Custom hooks have largely replaced them for most use cases, and thank goodness-hooks are much cleaner. But if you're working on an existing codebase, or if you're curious about React's evolution, understanding HOCs is still valuable. Plus, some third-party libraries still use them.

Think of HOCs as a way to "wrap" components with additional functionality, like wrapping a gift. The original component is still there, it just gets some extra bells and whistles attached.

A higher-order component is essentially a function that takes a component as an argument and returns a new component with additional props, state, or behavior. The pattern follows the higher-order function concept from functional programming, where functions can take other functions as arguments and return new functions.

::: important
**HOCs in the modern React landscape**

While HOCs were once a primary pattern for sharing logic between components, custom hooks now provide a cleaner, more composable alternative for most use cases. However, HOCs are still relevant when you need to enhance components at the component level rather than the hook level, or when working with class components that can't use hooks.
:::

Consider a simple example of adding authentication checks to components:

::: example

```jsx
// Traditional HOC approach
function withAuthentication(WrappedComponent) {
  return function AuthenticatedComponent(props) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
      // Check authentication status
      AuthService.getCurrentUser()
        .then(setUser)
        .catch(() => setUser(null))
        .finally(() => setLoading(false));
    }, []);

    if (loading) {
      return <div>Checking authentication...</div>;
    }

    if (!user) {
      return <div>Please log in to access this content.</div>;
    }

    return <WrappedComponent {...props} user={user} />;
  };
}

// Usage with HOC
const AuthenticatedPracticeSession = withAuthentication(PracticeSessionView);

// Modern hook approach (preferred)
function useAuthentication() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    AuthService.getCurrentUser()
      .then(setUser)
      .catch(() => setUser(null))
      .finally(() => setLoading(false));
  }, []);

  return { user, loading, isAuthenticated: !!user };
}

// Usage with hook
function PracticeSessionView() {
  const { user, loading, isAuthenticated } = useAuthentication();

  if (loading) return <div>Checking authentication...</div>;
  if (!isAuthenticated) return <div>Please log in to access this content.</div>;

  return (
    <div className="practice-session">
      <h2>Welcome, {user.name}!</h2>
      {/* Component content */}
    </div>
  );
}
```

:::

The hook approach is generally cleaner because it's more explicit about what data the component uses and doesn't create additional component layers in the React DevTools.

### Understanding HOC implementation patterns {.unnumbered .unlisted}

While HOCs are less common in new code, understanding their implementation patterns helps when working with existing codebases or certain library APIs.

::: example

```jsx
// HOC for adding loading and error handling to data fetching
function withDataFetching(WrappedComponent, dataFetcher) {
  return function DataFetchingComponent(props) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
      let cancelled = false;

      const fetchData = async () => {
        setLoading(true);
        setError(null);

        try {
          const result = await dataFetcher(props);
          if (!cancelled) {
            setData(result);
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

      fetchData();

      return () => {
        cancelled = true;
      };
    }, [props.userId, props.sessionId]); // Dependencies based on props

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;

    return (
      <WrappedComponent 
        {...props} 
        data={data}
        refetch={() => fetchData()}
      />
    );
  };
}

// Usage
const PracticeSessionsWithData = withDataFetching(
  PracticeSessionsList,
  ({ userId }) => PracticeSessionAPI.getByUser(userId)
);

// The modern hook equivalent (preferred)
function usePracticeSessionsData(userId) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await PracticeSessionAPI.getByUser(userId);
      setData(result);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
}
```

:::

### Composing multiple HOCs {.unnumbered .unlisted}

One of the challenges with HOCs is that they can become difficult to compose when you need multiple enhancements. This is one of the key reasons hooks became the preferred pattern.

::: example

```jsx
// Multiple HOCs create wrapper hell
const EnhancedComponent = withAuthentication(
  withDataFetching(
    withErrorBoundary(
      withTheme(
        PracticeSessionView
      )
    ),
    fetchSessionData
  )
);

// Alternative composition approach
function enhance(WrappedComponent) {
  return withAuthentication(
    withDataFetching(
      withErrorBoundary(
        withTheme(WrappedComponent)
      ),
      fetchSessionData
    )
  );
}

const EnhancedComponent = enhance(PracticeSessionView);

// Modern hook composition (much cleaner)
function PracticeSessionView() {
  const { user, isAuthenticated } = useAuthentication();
  const { data, loading, error } = usePracticeSessionsData(user?.id);
  const theme = useTheme();

  // Component implementation with all the enhanced functionality
  // without wrapper components
}
```

:::

The hook approach provides much cleaner composition and makes dependencies more explicit.

### When HOCs are still appropriate {.unnumbered .unlisted}

Despite being largely superseded by hooks, there are still some scenarios where HOCs might be the right choice:

::: example

```jsx
// 1. Working with class components that can't use hooks
class PracticeSessionClassComponent extends React.Component {
  render() {
    const { user, sessions, loading } = this.props;
    // Class component implementation
  }
}

const EnhancedClassComponent = withAuthentication(
  withDataFetching(PracticeSessionClassComponent, fetchSessions)
);

// 2. Component-level enhancements that affect rendering behavior
function withErrorBoundary(WrappedComponent) {
  return class ErrorBoundaryWrapper extends React.Component {
    constructor(props) {
      super(props);
      this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error) {
      return { hasError: true, error };
    }

    componentDidCatch(error, errorInfo) {
      console.error('Component caught error:', error, errorInfo);
    }

    render() {
      if (this.state.hasError) {
        return (
          <div className="error-fallback">
            <h3>Something went wrong</h3>
            <p>{this.state.error?.message}</p>
            <button onClick={() => this.setState({ hasError: false, error: null })}>
              Try Again
            </button>
          </div>
        );
      }

      return <WrappedComponent {...this.props} />;
    }
  };
}

// 3. Library integration where HOCs are the provided API
// Example: React Router's withRouter (legacy)
const ComponentWithRouter = withRouter(MyComponent);

// Example: Redux connect (legacy, replaced by hooks)
const ConnectedComponent = connect(
  mapStateToProps,
  mapDispatchToProps
)(MyComponent);
```

:::

### HOC best practices and common pitfalls {.unnumbered .unlisted}

When you do need to work with HOCs, understanding common patterns and pitfalls is important:

::: caution
**Common HOC pitfalls**

1. **Ref forwarding**: HOCs don't automatically forward refs, which can break component APIs
2. **Static method copying**: Static methods on the wrapped component aren't automatically copied
3. **Display names**: HOCs should set meaningful display names for debugging
4. **Props collision**: Be careful about prop name conflicts between the HOC and wrapped component
:::

::: example

```jsx
// Well-implemented HOC with best practices
function withPracticeTracking(WrappedComponent) {
  const WithPracticeTracking = React.forwardRef((props, ref) => {
    const [practiceTime, setPracticeTime] = useState(0);
    const [isTracking, setIsTracking] = useState(false);

    const startTracking = useCallback(() => {
      setIsTracking(true);
      // Tracking logic
    }, []);

    const stopTracking = useCallback(() => {
      setIsTracking(false);
      // Stop tracking and save data
    }, []);

    return (
      <WrappedComponent
        {...props}
        ref={ref}
        practiceTime={practiceTime}
        isTracking={isTracking}
        startTracking={startTracking}
        stopTracking={stopTracking}
      />
    );
  });

  // Set display name for debugging
  WithPracticeTracking.displayName = 
    `withPracticeTracking(${WrappedComponent.displayName || WrappedComponent.name})`;

  // Copy static methods if needed
  return hoistNonReactStatics(WithPracticeTracking, WrappedComponent);
}
```

:::

### Migrating from HOCs to hooks {.unnumbered .unlisted}

When modernizing codebases, you'll often need to migrate HOC patterns to custom hooks:

::: example

```jsx
// Legacy HOC pattern
function withSessionTimer(WrappedComponent) {
  return function SessionTimerWrapper(props) {
    const [startTime] = useState(Date.now());
    const [elapsed, setElapsed] = useState(0);

    useEffect(() => {
      const interval = setInterval(() => {
        setElapsed(Date.now() - startTime);
      }, 1000);

      return () => clearInterval(interval);
    }, [startTime]);

    return (
      <WrappedComponent 
        {...props} 
        sessionDuration={elapsed}
        formattedDuration={formatDuration(elapsed)}
      />
    );
  };
}

// Modern hook equivalent
function useSessionTimer() {
  const [startTime] = useState(Date.now());
  const [elapsed, setElapsed] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setElapsed(Date.now() - startTime);
    }, 1000);

    return () => clearInterval(interval);
  }, [startTime]);

  return {
    sessionDuration: elapsed,
    formattedDuration: formatDuration(elapsed),
    startTime
  };
}

// Migration allows for better composition and clearer dependencies
function PracticeSession() {
  const { sessionDuration, formattedDuration } = useSessionTimer();
  const { user } = useAuthentication();
  const { sessions, loading } = usePracticeSessions(user?.id);

  // Much clearer what this component depends on
}
```

:::

::: tip
**When to migrate HOCs to hooks**

Consider migrating HOCs to hooks when:
- You're actively maintaining the codebase
- The HOC logic doesn't require component-level error boundaries
- You're not constrained by class components
- The HOC creates complex composition chains
- You want to improve the developer experience and debugging
:::

Higher-order components represent an important part of React's history and remain relevant for understanding existing codebases and certain specialized use cases. However, for new development, custom hooks provide a more modern, composable, and maintainable approach to sharing logic between components.

## Context patterns for dependency injection

Now we're getting into some seriously powerful territory. React Context isn't just for passing user data or theme settings around-it's actually a fantastic tool for implementing dependency injection patterns that can make your entire application architecture cleaner and more testable.

I'll admit, when I first heard "dependency injection" in the context of React, my eyes glazed over a bit. It sounded like enterprise Java buzzword territory. But the concept is actually straightforward: instead of components creating their own dependencies (like API services or utilities), you inject those dependencies from the outside. It's like the difference between everyone in your office buying their own coffee machine versus having a central coffee service that everyone can use.

The magic happens when you combine Context with dependency injection. Suddenly you can swap out services for testing, provide different implementations for different environments, and eliminate a ton of prop drilling-all while keeping your components focused on what they do best: rendering UI.

Dependency injection is a design pattern where objects receive their dependencies from external sources rather than creating them internally. In React applications, this pattern helps you avoid prop drilling, makes components easier to test, and creates clear separation of concerns between business logic and presentation.

::: important
**Context vs. prop drilling**

Context excels at solving the "prop drilling" problem where props need to pass through many component levels to reach deeply nested children. However, Context should be used judiciously-not every piece of shared state needs Context. Consider Context when you have truly application-wide concerns or when prop drilling becomes unwieldy.
:::

Consider how a music practice app might inject various services throughout the component tree:

::: example

```jsx
// Traditional prop drilling approach (becomes unwieldy)
function App() {
  const apiService = new PracticeAPIService();
  const analyticsService = new AnalyticsService();
  const storageService = new LocalStorageService();
  
  return (
    <Dashboard 
      apiService={apiService}
      analyticsService={analyticsService}
      storageService={storageService}
    />
  );
}

function Dashboard({ apiService, analyticsService, storageService }) {
  return (
    <div>
      <PracticeHistory 
        apiService={apiService}
        analyticsService={analyticsService}
        storageService={storageService}
      />
      <SessionManager 
        apiService={apiService}
        analyticsService={analyticsService}
        storageService={storageService}
      />
    </div>
  );
}

// Context-based dependency injection (cleaner)
const ServicesContext = createContext();

function App() {
  const services = {
    api: new PracticeAPIService(),
    analytics: new AnalyticsService(),
    storage: new LocalStorageService()
  };
  
  return (
    <ServicesContext.Provider value={services}>
      <Dashboard />
    </ServicesContext.Provider>
  );
}

function useServices() {
  const context = useContext(ServicesContext);
  if (!context) {
    throw new Error('useServices must be used within ServicesProvider');
  }
  return context;
}

// Components can now access services directly
function PracticeHistory() {
  const { api, analytics } = useServices();
  // Use services without prop drilling
}
```

:::

### Building a service container with Context {.unnumbered .unlisted}

A service container is a centralized registry that manages the creation and lifecycle of application services. This pattern is particularly useful for managing API clients, analytics services, storage adapters, and other cross-cutting concerns.

::: example

```jsx
import React, { createContext, useContext, useMemo } from 'react';

// Define service interfaces for better type safety
class PracticeAPIService {
  constructor(baseURL, authToken) {
    this.baseURL = baseURL;
    this.authToken = authToken;
  }

  async getSessions(userId) {
    const response = await fetch(`${this.baseURL}/users/${userId}/sessions`, {
      headers: { Authorization: `Bearer ${this.authToken}` }
    });
    return response.json();
  }

  async createSession(sessionData) {
    const response = await fetch(`${this.baseURL}/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.authToken}`
      },
      body: JSON.stringify(sessionData)
    });
    return response.json();
  }

  async updateSession(sessionId, updates) {
    const response = await fetch(`${this.baseURL}/sessions/${sessionId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.authToken}`
      },
      body: JSON.stringify(updates)
    });
    return response.json();
  }
}

class AnalyticsService {
  constructor(trackingId) {
    this.trackingId = trackingId;
  }

  track(event, properties = {}) {
    // Analytics implementation
    console.log('Analytics:', event, properties);
  }

  trackPracticeSession(sessionData) {
    this.track('practice_session_completed', {
      duration: sessionData.duration,
      piece: sessionData.piece,
      difficulty: sessionData.difficulty
    });
  }
}

class StorageService {
  setItem(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }

  getItem(key) {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : null;
  }

  removeItem(key) {
    localStorage.removeItem(key);
  }
}

class NotificationService {
  show(message, type = 'info') {
    // Notification implementation
    console.log(`[${type.toUpperCase()}] ${message}`);
  }

  success(message) {
    this.show(message, 'success');
  }

  error(message) {
    this.show(message, 'error');
  }
}

// Service container context
const ServiceContext = createContext();

export function ServiceProvider({ children, config = {} }) {
  const services = useMemo(() => {
    // Initialize services with configuration
    const apiService = new PracticeAPIService(
      config.apiBaseURL || '/api',
      config.authToken
    );
    
    const analyticsService = new AnalyticsService(
      config.analyticsTrackingId
    );
    
    const storageService = new StorageService();
    const notificationService = new NotificationService();

    return {
      api: apiService,
      analytics: analyticsService,
      storage: storageService,
      notifications: notificationService
    };
  }, [config.apiBaseURL, config.authToken, config.analyticsTrackingId]);

  return (
    <ServiceContext.Provider value={services}>
      {children}
    </ServiceContext.Provider>
  );
}

export function useServices() {
  const context = useContext(ServiceContext);
  if (!context) {
    throw new Error('useServices must be used within ServiceProvider');
  }
  return context;
}

// Individual service hooks for more granular access
export function useAPI() {
  return useServices().api;
}

export function useAnalytics() {
  return useServices().analytics;
}

export function useStorage() {
  return useServices().storage;
}

export function useNotifications() {
  return useServices().notifications;
}
```

:::

### Advanced Context patterns for complex state management {.unnumbered .unlisted}

For more complex applications, you might need multiple Context providers that work together to manage different aspects of your application state and services.

::: example

```jsx
// User authentication context
const AuthContext = createContext();

function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const { api, analytics, storage } = useServices();

  useEffect(() => {
    // Check for stored authentication
    const storedAuth = storage.getItem('auth');
    if (storedAuth?.token) {
      api.setAuthToken(storedAuth.token);
      setUser(storedAuth.user);
    }
    setLoading(false);
  }, [api, storage]);

  const login = useCallback(async (credentials) => {
    const authData = await api.login(credentials);
    storage.setItem('auth', authData);
    api.setAuthToken(authData.token);
    setUser(authData.user);
    analytics.track('user_login', { userId: authData.user.id });
    return authData;
  }, [api, analytics, storage]);

  const logout = useCallback(() => {
    storage.removeItem('auth');
    api.setAuthToken(null);
    setUser(null);
    analytics.track('user_logout');
  }, [api, analytics, storage]);

  const value = {
    user,
    loading,
    isAuthenticated: !!user,
    login,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

// Practice data context that depends on auth
const PracticeDataContext = createContext();

function PracticeDataProvider({ children }) {
  const { user, isAuthenticated } = useAuth();
  const { api, analytics } = useServices();
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const loadSessions = useCallback(async () => {
    if (!isAuthenticated) return;

    setLoading(true);
    setError(null);

    try {
      const userSessions = await api.getSessions(user.id);
      setSessions(userSessions);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [api, user?.id, isAuthenticated]);

  useEffect(() => {
    loadSessions();
  }, [loadSessions]);

  const createSession = useCallback(async (sessionData) => {
    const newSession = await api.createSession({
      ...sessionData,
      userId: user.id
    });
    
    setSessions(prev => [newSession, ...prev]);
    analytics.trackPracticeSession(newSession);
    return newSession;
  }, [api, analytics, user?.id]);

  const updateSession = useCallback(async (sessionId, updates) => {
    const updatedSession = await api.updateSession(sessionId, updates);
    setSessions(prev => 
      prev.map(session => 
        session.id === sessionId ? updatedSession : session
      )
    );
    return updatedSession;
  }, [api]);

  const value = {
    sessions,
    loading,
    error,
    createSession,
    updateSession,
    refetch: loadSessions
  };

  return (
    <PracticeDataContext.Provider value={value}>
      {children}
    </PracticeDataContext.Provider>
  );
}

function usePracticeData() {
  const context = useContext(PracticeDataContext);
  if (!context) {
    throw new Error('usePracticeData must be used within PracticeDataProvider');
  }
  return context;
}

// Application root with provider composition
function App() {
  const config = {
    apiBaseURL: process.env.REACT_APP_API_URL,
    authToken: null, // Will be set by AuthProvider
    analyticsTrackingId: process.env.REACT_APP_ANALYTICS_ID
  };

  return (
    <ServiceProvider config={config}>
      <AuthProvider>
        <PracticeDataProvider>
          <Router>
            <Routes>
              <Route path="/login" element={<LoginPage />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/practice" element={<PracticeSession />} />
            </Routes>
          </Router>
        </PracticeDataProvider>
      </AuthProvider>
    </ServiceProvider>
  );
}
```

:::

### Context optimization patterns {.unnumbered .unlisted}

When using Context for complex state management, it's important to optimize for performance to prevent unnecessary re-renders throughout your component tree.

::: example

```jsx
// Split contexts to minimize re-renders
const UserDataContext = createContext();
const UserActionsContext = createContext();

function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Memoize actions to prevent unnecessary re-renders
  const actions = useMemo(() => ({
    updateProfile: async (updates) => {
      const updatedUser = await api.updateProfile(user.id, updates);
      setUser(updatedUser);
      return updatedUser;
    },
    
    changePassword: async (oldPassword, newPassword) => {
      await api.changePassword(user.id, oldPassword, newPassword);
    },
    
    deleteAccount: async () => {
      await api.deleteAccount(user.id);
      setUser(null);
    }
  }), [user?.id]);

  // Split data and actions into separate contexts
  return (
    <UserDataContext.Provider value={{ user, loading }}>
      <UserActionsContext.Provider value={actions}>
        {children}
      </UserActionsContext.Provider>
    </UserDataContext.Provider>
  );
}

// Components can subscribe to only what they need
function UserProfile() {
  const { user, loading } = useContext(UserDataContext);
  // This component only re-renders when user data changes
  
  if (loading) return <div>Loading...</div>;
  
  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}

function UserActions() {
  const { updateProfile } = useContext(UserActionsContext);
  // This component only re-renders when actions change (rarely)
  
  return (
    <button onClick={() => updateProfile({ name: 'New Name' })}>
      Update Profile
    </button>
  );
}

// Context selector pattern for fine-grained subscriptions
function createContextSelector(context) {
  return function useContextSelector(selector) {
    const value = useContext(context);
    const selectedValue = selector(value);
    
    // This would need a more sophisticated implementation
    // to prevent re-renders when non-selected values change
    return selectedValue;
  };
}

const usePracticeDataSelector = createContextSelector(PracticeDataContext);

function SessionCount() {
  // Only re-renders when session count changes
  const sessionCount = usePracticeDataSelector(data => data.sessions.length);
  
  return <div>Total sessions: {sessionCount}</div>;
}
```

:::

### Testing components with Context dependencies {.unnumbered .unlisted}

One of the major benefits of dependency injection through Context is improved testability. You can easily provide mock services and controlled state for testing.

::: example

```jsx
// Test utilities for Context providers
export function createTestServiceProvider(overrides = {}) {
  const mockServices = {
    api: {
      getSessions: jest.fn().mockResolvedValue([]),
      createSession: jest.fn().mockResolvedValue({ id: 'test-session' }),
      updateSession: jest.fn().mockResolvedValue({ id: 'test-session' }),
      ...overrides.api
    },
    analytics: {
      track: jest.fn(),
      trackPracticeSession: jest.fn(),
      ...overrides.analytics
    },
    storage: {
      getItem: jest.fn().mockReturnValue(null),
      setItem: jest.fn(),
      removeItem: jest.fn(),
      ...overrides.storage
    },
    notifications: {
      show: jest.fn(),
      success: jest.fn(),
      error: jest.fn(),
      ...overrides.notifications
    }
  };

  return function TestServiceProvider({ children }) {
    return (
      <ServiceContext.Provider value={mockServices}>
        {children}
      </ServiceContext.Provider>
    );
  };
}

export function createTestAuthProvider(userOverrides = {}) {
  const mockUser = {
    id: 'test-user-id',
    name: 'Test User',
    email: 'test@example.com',
    ...userOverrides
  };

  const mockAuthValue = {
    user: mockUser,
    loading: false,
    isAuthenticated: true,
    login: jest.fn().mockResolvedValue(mockUser),
    logout: jest.fn()
  };

  return function TestAuthProvider({ children }) {
    return (
      <AuthContext.Provider value={mockAuthValue}>
        {children}
      </AuthContext.Provider>
    );
  };
}

// Example test
describe('PracticeSessionForm', () => {
  it('creates a new practice session', async () => {
    const mockCreateSession = jest.fn().mockResolvedValue({
      id: 'new-session',
      piece: 'Test Piece'
    });

    const TestServiceProvider = createTestServiceProvider({
      api: { createSession: mockCreateSession }
    });
    
    const TestAuthProvider = createTestAuthProvider();

    render(
      <TestServiceProvider>
        <TestAuthProvider>
          <PracticeSessionForm />
        </TestAuthProvider>
      </TestServiceProvider>
    );

    // Fill out form
    fireEvent.change(screen.getByLabelText(/piece name/i), {
      target: { value: 'Test Piece' }
    });

    // Submit form
    fireEvent.click(screen.getByRole('button', { name: /create session/i }));

    await waitFor(() => {
      expect(mockCreateSession).toHaveBeenCalledWith({
        piece: 'Test Piece',
        userId: 'test-user-id'
      });
    });
  });
});
```

:::

### When to use Context for dependency injection {.unnumbered .unlisted}

Context-based dependency injection is most valuable when you have:

- **Cross-cutting concerns**: Services that many components need (API clients, analytics, notifications)
- **Configuration data**: Application settings, feature flags, or environment-specific values
- **Authentication state**: User information and authentication status
- **Deep component trees**: When prop drilling becomes unwieldy
- **Testing requirements**: When you need to mock dependencies for testing

::: caution
**Context performance considerations**

Remember that Context providers trigger re-renders in all consuming components when their value changes. For frequently changing data, consider:
- Splitting contexts by update frequency
- Using state management libraries for complex state
- Implementing context selectors to minimize re-renders
- Keeping Context values stable with useMemo and useCallback
:::

::: tip
**Best practices for Context dependency injection**

1. **Create focused contexts**: Don't put everything in one giant context
2. **Provide clear error boundaries**: Always check if context is available
3. **Use TypeScript**: Type your contexts for better developer experience
4. **Mock for testing**: Create test utilities for easy mocking
5. **Document dependencies**: Make it clear what services components expect
:::

Context patterns for dependency injection provide a powerful way to structure React applications with clear separation of concerns, improved testability, and reduced coupling between components. When implemented thoughtfully, these patterns create a foundation for scalable and maintainable applications.

## Advanced custom hooks patterns

Here's where things get really fun. If basic custom hooks are like learning to ride a bike, advanced custom hook patterns are like learning to do motorcycle stunts. We're going to build hooks that manage state machines, coordinate complex async operations, and basically become the Swiss Army knife of your React applications.

I've got to be honest-this is where I really fell in love with React hooks. When they first came out, I thought "okay, nice way to use state in function components." But when I started building hooks that could orchestrate complex workflows, manage resources intelligently, and provide clean abstractions for gnarly business logic... that's when I realized hooks weren't just a new API, they were a completely new way of thinking about React architecture.

We're going to cover patterns that might seem overkill for simple apps, but trust me-when you're building something complex, these patterns will save your sanity. State machines, resource management, async coordination, hook factories-it sounds fancy, but it's really about taking the chaos of complex applications and making it manageable.

The power of custom hooks lies in their composability and reusability. Unlike higher-order components or render props, hooks can be easily combined, tested in isolation, and provide clear interfaces for the logic they encapsulate. As your applications grow in complexity, mastering advanced hook patterns becomes essential for maintaining clean, maintainable code.

::: important
**Hooks as architectural tools**

Advanced custom hooks serve as more than just state management-they act as architectural boundaries that encapsulate business logic, coordinate side effects, and provide stable interfaces between your components and complex application concerns. Well-designed hooks can eliminate the need for external state management libraries in many cases.
:::

### State machine patterns with hooks {.unnumbered .unlisted}

Complex user interactions often benefit from explicit state machine modeling. Custom hooks can encapsulate state machines that manage intricate workflows with clear state transitions and side effects.

::: example

```jsx
import { useState, useCallback, useRef, useEffect } from 'react';

// Practice session state machine hook
function usePracticeSessionStateMachine(initialSession = null) {
  const [state, setState] = useState('idle');
  const [session, setSession] = useState(initialSession);
  const [startTime, setStartTime] = useState(null);
  const [elapsedTime, setElapsedTime] = useState(0);
  const [error, setError] = useState(null);
  
  const intervalRef = useRef(null);
  const { api, analytics } = useServices();

  // State machine transitions
  const transitions = {
    idle: {
      start: 'preparing',
      load: 'loading'
    },
    loading: {
      success: 'idle',
      error: 'error'
    },
    preparing: {
      ready: 'active',
      cancel: 'idle',
      error: 'error'
    },
    active: {
      pause: 'paused',
      complete: 'completing',
      error: 'error'
    },
    paused: {
      resume: 'active',
      complete: 'completing',
      cancel: 'idle'
    },
    completing: {
      success: 'completed',
      error: 'error'
    },
    completed: {
      reset: 'idle'
    },
    error: {
      retry: 'idle',
      reset: 'idle'
    }
  };

  // Helper function to validate transitions
  const canTransition = useCallback((action) => {
    return transitions[state] && transitions[state][action];
  }, [state]);

  // Safe transition function
  const transition = useCallback((action, payload = null) => {
    if (!canTransition(action)) {
      console.warn(`Invalid transition: ${action} from state ${state}`);
      return false;
    }

    const newState = transitions[state][action];
    setState(newState);

    // Handle side effects based on state transitions
    switch (newState) {
      case 'preparing':
        setError(null);
        setElapsedTime(0);
        break;
      
      case 'active':
        setStartTime(Date.now());
        startTimer();
        analytics.track('practice_session_started', { 
          sessionId: session?.id,
          piece: session?.piece 
        });
        break;
      
      case 'paused':
        pauseTimer();
        analytics.track('practice_session_paused', { 
          sessionId: session?.id,
          duration: elapsedTime 
        });
        break;
      
      case 'completing':
        pauseTimer();
        saveSession();
        break;
      
      case 'completed':
        analytics.track('practice_session_completed', {
          sessionId: session?.id,
          totalDuration: elapsedTime,
          piece: session?.piece
        });
        break;
      
      case 'error':
        pauseTimer();
        if (payload) setError(payload);
        break;
    }

    return true;
  }, [state, session, elapsedTime, analytics]);

  // Timer management
  const startTimer = useCallback(() => {
    if (intervalRef.current) return;
    
    intervalRef.current = setInterval(() => {
      setElapsedTime(prev => prev + 1);
    }, 1000);
  }, []);

  const pauseTimer = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  // Session management
  const saveSession = useCallback(async () => {
    try {
      const sessionData = {
        ...session,
        duration: elapsedTime,
        completedAt: new Date().toISOString()
      };

      if (session?.id) {
        await api.updateSession(session.id, sessionData);
      } else {
        const newSession = await api.createSession(sessionData);
        setSession(newSession);
      }

      transition('success');
    } catch (err) {
      transition('error', err.message);
    }
  }, [session, elapsedTime, api, transition]);

  // Public API
  const actions = {
    startSession: (sessionData) => {
      setSession(sessionData);
      return transition('start');
    },
    
    markReady: () => transition('ready'),
    
    pauseSession: () => transition('pause'),
    
    resumeSession: () => transition('resume'),
    
    completeSession: () => transition('complete'),
    
    cancelSession: () => {
      pauseTimer();
      setSession(null);
      setElapsedTime(0);
      return transition('cancel');
    },
    
    resetSession: () => {
      pauseTimer();
      setSession(null);
      setElapsedTime(0);
      setError(null);
      return transition('reset');
    },
    
    retryAfterError: () => transition('retry')
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  return {
    state,
    session,
    elapsedTime,
    error,
    actions,
    canTransition,
    isActive: state === 'active',
    isPaused: state === 'paused',
    isCompleted: state === 'completed',
    hasError: state === 'error'
  };
}
```

:::

This state machine hook provides a robust foundation for managing complex practice session workflows with clear state transitions and side effect management.

### Data synchronization and caching patterns {.unnumbered .unlisted}

Advanced applications often need to coordinate data from multiple sources while maintaining consistency and performance. Custom hooks can provide sophisticated caching and synchronization strategies.

::: example

```jsx
// Advanced data synchronization hook with caching
function useDataSync(sources, options = {}) {
  const {
    refreshInterval = 30000,
    retryAttempts = 3,
    retryDelay = 1000,
    enableOptimisticUpdates = true,
    cacheStrategy = 'memory'
  } = options;

  const [data, setData] = useState({});
  const [loading, setLoading] = useState({});
  const [errors, setErrors] = useState({});
  const [lastSync, setLastSync] = useState({});
  
  const cache = useRef(new Map());
  const subscriptions = useRef(new Map());
  const retryTimeouts = useRef(new Map());

  // Cache management
  const getCacheKey = useCallback((source, params) => {
    return `${source.key}-${JSON.stringify(params || {})}`;
  }, []);

  const getCachedData = useCallback((cacheKey) => {
    if (cacheStrategy === 'none') return null;
    return cache.current.get(cacheKey);
  }, [cacheStrategy]);

  const setCachedData = useCallback((cacheKey, data, ttl = 300000) => {
    if (cacheStrategy === 'none') return;
    
    cache.current.set(cacheKey, {
      data,
      timestamp: Date.now(),
      ttl
    });
  }, [cacheStrategy]);

  const isCacheValid = useCallback((cachedItem) => {
    if (!cachedItem) return false;
    return Date.now() - cachedItem.timestamp < cachedItem.ttl;
  }, []);

  // Data fetching with retry logic
  const fetchData = useCallback(async (source, params = {}, attempt = 1) => {
    const cacheKey = getCacheKey(source, params);
    
    // Check cache first
    const cachedItem = getCachedData(cacheKey);
    if (isCacheValid(cachedItem)) {
      setData(prev => ({ ...prev, [source.key]: cachedItem.data }));
      return cachedItem.data;
    }

    setLoading(prev => ({ ...prev, [source.key]: true }));
    setErrors(prev => ({ ...prev, [source.key]: null }));

    try {
      const result = await source.fetch(params);
      
      setData(prev => ({ ...prev, [source.key]: result }));
      setLastSync(prev => ({ ...prev, [source.key]: Date.now() }));
      setCachedData(cacheKey, result);
      
      return result;
    } catch (error) {
      if (attempt < retryAttempts) {
        const timeout = setTimeout(() => {
          fetchData(source, params, attempt + 1);
        }, retryDelay * attempt);
        
        retryTimeouts.current.set(cacheKey, timeout);
      } else {
        setErrors(prev => ({ ...prev, [source.key]: error.message }));
      }
      throw error;
    } finally {
      setLoading(prev => ({ ...prev, [source.key]: false }));
    }
  }, [getCacheKey, getCachedData, setCachedData, isCacheValid, retryAttempts, retryDelay]);

  // Optimistic updates
  const optimisticUpdate = useCallback((sourceKey, updater) => {
    if (!enableOptimisticUpdates) return;
    
    setData(prev => ({
      ...prev,
      [sourceKey]: updater(prev[sourceKey])
    }));
  }, [enableOptimisticUpdates]);

  // Mutation with optimistic updates and rollback
  const mutate = useCallback(async (source, mutationData, optimisticUpdater) => {
    const rollbackData = data[source.key];
    
    try {
      // Apply optimistic update
      if (optimisticUpdater) {
        optimisticUpdate(source.key, optimisticUpdater);
      }

      // Perform mutation
      const result = await source.mutate(mutationData);
      
      // Update cache with real result
      const cacheKey = getCacheKey(source, {});
      setCachedData(cacheKey, result);
      setData(prev => ({ ...prev, [source.key]: result }));
      
      return result;
    } catch (error) {
      // Rollback optimistic update
      if (optimisticUpdater && rollbackData) {
        setData(prev => ({ ...prev, [source.key]: rollbackData }));
      }
      
      setErrors(prev => ({ ...prev, [source.key]: error.message }));
      throw error;
    }
  }, [data, optimisticUpdate, getCacheKey, setCachedData]);

  // Subscription management for real-time updates
  const subscribe = useCallback((source, params = {}) => {
    if (!source.subscribe) return;

    const subscriptionKey = getCacheKey(source, params);
    
    if (subscriptions.current.has(subscriptionKey)) {
      return subscriptions.current.get(subscriptionKey);
    }

    const subscription = source.subscribe(params, (newData) => {
      setData(prev => ({ ...prev, [source.key]: newData }));
      setCachedData(subscriptionKey, newData);
      setLastSync(prev => ({ ...prev, [source.key]: Date.now() }));
    });

    subscriptions.current.set(subscriptionKey, subscription);
    return subscription;
  }, [getCacheKey, setCachedData]);

  // Initialize data sources
  useEffect(() => {
    sources.forEach(source => {
      fetchData(source, source.params);
      
      if (source.subscribe) {
        subscribe(source, source.params);
      }
    });
  }, [sources, fetchData, subscribe]);

  // Set up refresh intervals
  useEffect(() => {
    if (!refreshInterval) return;

    const interval = setInterval(() => {
      sources.forEach(source => {
        if (!source.disableAutoRefresh) {
          fetchData(source, source.params);
        }
      });
    }, refreshInterval);

    return () => clearInterval(interval);
  }, [sources, refreshInterval, fetchData]);

  // Cleanup
  useEffect(() => {
    return () => {
      // Clear retry timeouts
      retryTimeouts.current.forEach(timeout => clearTimeout(timeout));
      
      // Clean up subscriptions
      subscriptions.current.forEach(subscription => {
        if (typeof subscription.unsubscribe === 'function') {
          subscription.unsubscribe();
        }
      });
    };
  }, []);

  return {
    data,
    loading,
    errors,
    lastSync,
    refetch: (sourceKey, params) => {
      const source = sources.find(s => s.key === sourceKey);
      return source ? fetchData(source, params || source.params) : null;
    },
    mutate,
    clearCache: (sourceKey) => {
      const source = sources.find(s => s.key === sourceKey);
      if (source) {
        const cacheKey = getCacheKey(source, source.params);
        cache.current.delete(cacheKey);
      }
    },
    subscribe: (sourceKey, params) => {
      const source = sources.find(s => s.key === sourceKey);
      return source ? subscribe(source, params) : null;
    }
  };
}

// Usage example
function PracticeStatsDashboard({ userId }) {
  const dataSources = [
    {
      key: 'sessions',
      fetch: (params) => api.getSessions(userId, params),
      mutate: (data) => api.createSession(data),
      subscribe: (params, callback) => api.subscribeToSessions(userId, callback),
      params: { limit: 50, sortBy: 'date' }
    },
    {
      key: 'analytics',
      fetch: () => api.getAnalytics(userId),
      params: { timeframe: '30d' },
      disableAutoRefresh: false
    },
    {
      key: 'goals',
      fetch: () => api.getGoals(userId),
      mutate: (data) => api.updateGoal(data.id, data)
    }
  ];

  const { 
    data, 
    loading, 
    errors, 
    refetch, 
    mutate 
  } = useDataSync(dataSources, {
    refreshInterval: 60000,
    enableOptimisticUpdates: true,
    cacheStrategy: 'memory'
  });

  const createSession = useCallback(async (sessionData) => {
    const sessionsSource = dataSources.find(s => s.key === 'sessions');
    
    return mutate(
      sessionsSource,
      sessionData,
      (currentSessions) => [sessionData, ...currentSessions]
    );
  }, [mutate, dataSources]);

  if (loading.sessions) return <div>Loading...</div>;
  if (errors.sessions) return <div>Error: {errors.sessions}</div>;

  return (
    <div className="practice-stats-dashboard">
      <SessionsList 
        sessions={data.sessions || []} 
        onCreateSession={createSession}
      />
      <AnalyticsPanel analytics={data.analytics} />
      <GoalsPanel goals={data.goals} />
    </div>
  );
}
```

:::

### Async coordination and effect management {.unnumbered .unlisted}

Complex applications often need to coordinate multiple asynchronous operations with sophisticated error handling and dependency management.

::: example

```jsx
// Advanced async coordination hook
function useAsyncCoordinator() {
  const [operations, setOperations] = useState(new Map());
  const [dependencies, setDependencies] = useState(new Map());
  const operationRefs = useRef(new Map());

  // Register an async operation
  const registerOperation = useCallback((id, operation, options = {}) => {
    const {
      dependencies: deps = [],
      timeout = 30000,
      retryCount = 0,
      rollback = null,
      onSuccess = null,
      onError = null
    } = options;

    setOperations(prev => new Map(prev).set(id, {
      id,
      operation,
      status: 'pending',
      result: null,
      error: null,
      startTime: null,
      endTime: null,
      timeout,
      retryCount,
      retriesLeft: retryCount,
      rollback,
      onSuccess,
      onError
    }));

    if (deps.length > 0) {
      setDependencies(prev => new Map(prev).set(id, deps));
    }

    return id;
  }, []);

  // Execute operations respecting dependencies
  const executeOperations = useCallback(async () => {
    const operationsMap = new Map(operations);
    const dependenciesMap = new Map(dependencies);
    const executed = new Set();
    const executing = new Set();

    const canExecute = (operationId) => {
      const deps = dependenciesMap.get(operationId) || [];
      return deps.every(depId => executed.has(depId));
    };

    const executeOperation = async (operationId) => {
      if (executing.has(operationId) || executed.has(operationId)) {
        return;
      }

      const operation = operationsMap.get(operationId);
      if (!operation || operation.status !== 'pending') {
        return;
      }

      executing.add(operationId);

      // Update operation status
      setOperations(prev => {
        const newMap = new Map(prev);
        const op = newMap.get(operationId);
        if (op) {
          op.status = 'running';
          op.startTime = Date.now();
        }
        return newMap;
      });

      try {
        // Set up timeout
        const timeoutPromise = new Promise((_, reject) => {
          setTimeout(() => reject(new Error('Operation timeout')), operation.timeout);
        });

        // Execute with timeout
        const result = await Promise.race([
          operation.operation(),
          timeoutPromise
        ]);

        // Success
        setOperations(prev => {
          const newMap = new Map(prev);
          const op = newMap.get(operationId);
          if (op) {
            op.status = 'completed';
            op.result = result;
            op.endTime = Date.now();
          }
          return newMap;
        });

        if (operation.onSuccess) {
          operation.onSuccess(result);
        }

        executed.add(operationId);
        executing.delete(operationId);

        // Execute dependent operations
        for (const [depId, deps] of dependenciesMap.entries()) {
          if (deps.includes(operationId) && canExecute(depId)) {
            executeOperation(depId);
          }
        }

      } catch (error) {
        // Handle retry
        if (operation.retriesLeft > 0) {
          setOperations(prev => {
            const newMap = new Map(prev);
            const op = newMap.get(operationId);
            if (op) {
              op.retriesLeft--;
              op.status = 'pending';
            }
            return newMap;
          });

          executing.delete(operationId);

          // Retry after delay
          setTimeout(() => executeOperation(operationId), 1000);
          return;
        }

        // Failure
        setOperations(prev => {
          const newMap = new Map(prev);
          const op = newMap.get(operationId);
          if (op) {
            op.status = 'failed';
            op.error = error.message;
            op.endTime = Date.now();
          }
          return newMap;
        });

        if (operation.onError) {
          operation.onError(error);
        }

        executing.delete(operationId);

        // Execute rollback if available
        if (operation.rollback) {
          try {
            await operation.rollback();
          } catch (rollbackError) {
            console.error('Rollback failed:', rollbackError);
          }
        }
      }
    };

    // Start executing operations that have no dependencies
    for (const [operationId] of operationsMap) {
      if (canExecute(operationId)) {
        executeOperation(operationId);
      }
    }
  }, [operations, dependencies]);

  // Get operation status
  const getOperationStatus = useCallback((operationId) => {
    return operations.get(operationId);
  }, [operations]);

  // Check if all operations are complete
  const isComplete = useMemo(() => {
    for (const operation of operations.values()) {
      if (operation.status === 'pending' || operation.status === 'running') {
        return false;
      }
    }
    return operations.size > 0;
  }, [operations]);

  // Check if any operation failed
  const hasFailed = useMemo(() => {
    for (const operation of operations.values()) {
      if (operation.status === 'failed') {
        return true;
      }
    }
    return false;
  }, [operations]);

  // Get all results
  const results = useMemo(() => {
    const results = {};
    for (const [id, operation] of operations) {
      if (operation.status === 'completed') {
        results[id] = operation.result;
      }
    }
    return results;
  }, [operations]);

  // Clear all operations
  const reset = useCallback(() => {
    setOperations(new Map());
    setDependencies(new Map());
    operationRefs.current.clear();
  }, []);

  return {
    registerOperation,
    executeOperations,
    getOperationStatus,
    isComplete,
    hasFailed,
    results,
    reset,
    operations: Array.from(operations.values())
  };
}

// Usage example for complex practice session initialization
function usePracticeSessionInitialization(sessionConfig) {
  const coordinator = useAsyncCoordinator();
  const [initializationState, setInitializationState] = useState('idle');

  const initializeSession = useCallback(async () => {
    setInitializationState('initializing');
    coordinator.reset();

    // Register all operations with their dependencies
    coordinator.registerOperation('loadUser', 
      () => api.getCurrentUser(),
      { timeout: 5000 }
    );

    coordinator.registerOperation('loadPiece',
      () => api.getPiece(sessionConfig.pieceId),
      { dependencies: ['loadUser'], timeout: 10000 }
    );

    coordinator.registerOperation('loadSettings',
      () => api.getUserSettings(),
      { dependencies: ['loadUser'] }
    );

    coordinator.registerOperation('initializeAudio',
      () => audioService.initialize(),
      { dependencies: ['loadSettings'], timeout: 15000 }
    );

    coordinator.registerOperation('createSession',
      () => api.createSession({
        pieceId: sessionConfig.pieceId,
        userId: coordinator.results.loadUser?.id
      }),
      { 
        dependencies: ['loadUser', 'loadPiece'],
        rollback: () => api.deleteSession(coordinator.results.createSession?.id)
      }
    );

    coordinator.registerOperation('setupRecording',
      () => recordingService.setup(coordinator.results.createSession),
      { 
        dependencies: ['createSession', 'initializeAudio'],
        rollback: () => recordingService.cleanup()
      }
    );

    try {
      await coordinator.executeOperations();
      
      if (coordinator.hasFailed) {
        setInitializationState('failed');
      } else if (coordinator.isComplete) {
        setInitializationState('ready');
      }
    } catch (error) {
      setInitializationState('failed');
    }
  }, [sessionConfig, coordinator]);

  return {
    initializeSession,
    state: initializationState,
    operations: coordinator.operations,
    results: coordinator.results,
    isReady: initializationState === 'ready',
    hasFailed: coordinator.hasFailed
  };
}
```

:::

### Resource management and cleanup patterns {.unnumbered .unlisted}

Advanced hooks often need to manage complex resources with sophisticated cleanup strategies to prevent memory leaks and resource contention.

::: example

```jsx
// Advanced resource management hook
function useResourceManager() {
  const resources = useRef(new Map());
  const cleanupTasks = useRef(new Map());
  const resourceGroups = useRef(new Map());

  // Register a resource with cleanup
  const registerResource = useCallback((id, resource, cleanup, group = 'default') => {
    // Clean up existing resource with same ID
    if (resources.current.has(id)) {
      releaseResource(id);
    }

    resources.current.set(id, resource);
    cleanupTasks.current.set(id, cleanup);

    // Add to group
    if (!resourceGroups.current.has(group)) {
      resourceGroups.current.set(group, new Set());
    }
    resourceGroups.current.get(group).add(id);

    return resource;
  }, []);

  // Release a specific resource
  const releaseResource = useCallback(async (id) => {
    const resource = resources.current.get(id);
    const cleanup = cleanupTasks.current.get(id);

    if (cleanup) {
      try {
        await cleanup(resource);
      } catch (error) {
        console.error(`Failed to cleanup resource ${id}:`, error);
      }
    }

    resources.current.delete(id);
    cleanupTasks.current.delete(id);

    // Remove from all groups
    for (const group of resourceGroups.current.values()) {
      group.delete(id);
    }
  }, []);

  // Release all resources in a group
  const releaseGroup = useCallback(async (groupName) => {
    const group = resourceGroups.current.get(groupName);
    if (!group) return;

    const promises = Array.from(group).map(id => releaseResource(id));
    await Promise.allSettled(promises);
    
    resourceGroups.current.delete(groupName);
  }, [releaseResource]);

  // Release all resources
  const releaseAll = useCallback(async () => {
    const promises = Array.from(resources.current.keys()).map(id => releaseResource(id));
    await Promise.allSettled(promises);
    
    resources.current.clear();
    cleanupTasks.current.clear();
    resourceGroups.current.clear();
  }, [releaseResource]);

  // Get resource by ID
  const getResource = useCallback((id) => {
    return resources.current.get(id);
  }, []);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      releaseAll();
    };
  }, [releaseAll]);

  return {
    registerResource,
    releaseResource,
    releaseGroup,
    releaseAll,
    getResource,
    resourceCount: resources.current.size
  };
}

// Specialized hook for practice session resources
function usePracticeSessionResources() {
  const resourceManager = useResourceManager();
  const [audioContext, setAudioContext] = useState(null);
  const [mediaRecorder, setMediaRecorder] = useState(null);

  // Initialize audio context
  const initializeAudio = useCallback(async () => {
    const context = new (window.AudioContext || window.webkitAudioContext)();
    
    resourceManager.registerResource(
      'audioContext',
      context,
      (ctx) => ctx.close(),
      'audio'
    );

    setAudioContext(context);
    return context;
  }, [resourceManager]);

  // Set up media recording
  const setupRecording = useCallback(async () => {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const recorder = new MediaRecorder(stream);
    
    resourceManager.registerResource(
      'mediaStream',
      stream,
      (stream) => stream.getTracks().forEach(track => track.stop()),
      'recording'
    );

    resourceManager.registerResource(
      'mediaRecorder',
      recorder,
      (recorder) => {
        if (recorder.state !== 'inactive') {
          recorder.stop();
        }
      },
      'recording'
    );

    setMediaRecorder(recorder);
    return recorder;
  }, [resourceManager]);

  // Set up metronome
  const setupMetronome = useCallback(async () => {
    if (!audioContext) {
      throw new Error('Audio context not initialized');
    }

    const metronome = new MetronomeService(audioContext);
    
    resourceManager.registerResource(
      'metronome',
      metronome,
      (metronome) => metronome.stop(),
      'audio'
    );

    return metronome;
  }, [audioContext, resourceManager]);

  // Clean up session resources
  const cleanupSession = useCallback(async () => {
    await resourceManager.releaseGroup('recording');
    setMediaRecorder(null);
  }, [resourceManager]);

  return {
    audioContext,
    mediaRecorder,
    initializeAudio,
    setupRecording,
    setupMetronome,
    cleanupSession,
    cleanupAll: resourceManager.releaseAll,
    getResource: resourceManager.getResource
  };
}
```

:::

### Composable hook factories {.unnumbered .unlisted}

Advanced patterns often involve creating hooks that generate other hooks, providing flexible abstractions for common patterns.

::: example

```jsx
// Factory for creating data management hooks
function createDataHook(config) {
  const {
    key,
    fetcher,
    defaultValue = null,
    cacheTime = 300000,
    staleTime = 60000,
    refetchOnMount = true,
    refetchOnWindowFocus = false
  } = config;

  return function useData(params = {}, options = {}) {
    const mergedOptions = { ...config, ...options };
    const cacheKey = `${key}-${JSON.stringify(params)}`;
    
    const [data, setData] = useState(defaultValue);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [lastFetch, setLastFetch] = useState(null);
    
    const fetchData = useCallback(async (force = false) => {
      // Check if data is still fresh
      if (!force && lastFetch && Date.now() - lastFetch < staleTime) {
        return data;
      }

      setLoading(true);
      setError(null);

      try {
        const result = await fetcher(params);
        setData(result);
        setLastFetch(Date.now());
        return result;
      } catch (err) {
        setError(err.message);
        throw err;
      } finally {
        setLoading(false);
      }
    }, [params, lastFetch, staleTime, data]);

    // Initial fetch
    useEffect(() => {
      if (refetchOnMount) {
        fetchData();
      }
    }, [fetchData, refetchOnMount]);

    // Window focus refetch
    useEffect(() => {
      if (!refetchOnWindowFocus) return;

      const handleFocus = () => fetchData();
      window.addEventListener('focus', handleFocus);
      return () => window.removeEventListener('focus', handleFocus);
    }, [fetchData, refetchOnWindowFocus]);

    return {
      data,
      loading,
      error,
      refetch: fetchData,
      isStale: lastFetch && Date.now() - lastFetch > staleTime
    };
  };
}

// Factory usage
const usePracticeSessions = createDataHook({
  key: 'practiceSessions',
  fetcher: (params) => api.getSessions(params.userId),
  staleTime: 30000,
  refetchOnWindowFocus: true
});

const usePieceDetails = createDataHook({
  key: 'pieceDetails',
  fetcher: (params) => api.getPiece(params.pieceId),
  cacheTime: 600000,
  staleTime: 300000
});

// Usage in components
function PracticeHistory({ userId }) {
  const { data: sessions, loading, error, refetch } = usePracticeSessions({ userId });
  
  // Component implementation
}
```

:::

These advanced custom hook patterns provide powerful abstractions for managing complex application logic while maintaining clean component interfaces. They demonstrate how hooks can serve as architectural tools that encapsulate sophisticated business logic and provide stable, reusable interfaces for components.

## Provider patterns and dependency injection

Now let's level up our architectural game. We talked about basic Context for dependency injection earlier, but provider patterns can do so much more than just avoid prop drilling. When done right, providers become the backbone of your entire application-they can replace complex state management libraries, coordinate services, and create clean architectural boundaries that make your code a joy to work with.

I remember the first time I built a comprehensive provider architecture. I was working on a complex music education platform, and I was drowning in prop drilling, scattered state, and components that knew way too much about the services they used. After implementing a proper provider hierarchy, it felt like someone had turned on the lights in a dark room. Suddenly everything had its place, dependencies were clear, and testing became actually enjoyable.

The secret sauce is thinking of providers not just as state containers, but as service boundaries. They define what parts of your app have access to what resources, and they make the implicit dependencies in your application explicit and manageable.

The provider pattern's strength lies in its ability to create clear architectural boundaries while maintaining flexibility and testability. Advanced provider patterns can manage complex application state, coordinate multiple services, and provide elegant solutions for cross-cutting concerns like authentication, theming, and API management.

::: important
**Providers as architectural foundation**

Well-designed provider patterns form the backbone of scalable React applications. They provide dependency injection, state management, and service coordination while maintaining clear separation of concerns. Advanced provider architectures can eliminate the need for external state management libraries in many applications.
:::

### Hierarchical provider composition {.unnumbered .unlisted}

Complex applications benefit from hierarchical provider structures that allow for granular control over dependencies and state scope. This pattern enables different parts of your application to have access to different sets of services and state.

::: example

```jsx
// Base provider system
function createProviderHierarchy() {
  const providers = new Map();
  const dependencies = new Map();

  // Register a provider with its dependencies
  const registerProvider = (name, ProviderComponent, deps = []) => {
    providers.set(name, ProviderComponent);
    dependencies.set(name, deps);
  };

  // Build provider tree respecting dependencies
  const buildProviderTree = (requestedProviders, children) => {
    const resolved = new Set();
    const resolving = new Set();

    const resolveProvider = (name) => {
      if (resolved.has(name)) return null;
      if (resolving.has(name)) {
        throw new Error(`Circular dependency detected: ${name}`);
      }

      resolving.add(name);
      
      const deps = dependencies.get(name) || [];
      const ProviderComponent = providers.get(name);
      
      if (!ProviderComponent) {
        throw new Error(`Provider not found: ${name}`);
      }

      // Resolve dependencies first
      const resolvedDeps = deps
        .filter(dep => !resolved.has(dep))
        .map(dep => resolveProvider(dep))
        .filter(Boolean);

      resolving.delete(name);
      resolved.add(name);

      return { name, ProviderComponent, dependencies: resolvedDeps };
    };

    // Resolve all requested providers
    const providerTree = requestedProviders.map(name => resolveProvider(name));

    // Build nested provider structure
    const buildNested = (providers, children) => {
      if (providers.length === 0) return children;

      const [first, ...rest] = providers;
      const { ProviderComponent } = first;

      return (
        <ProviderComponent>
          {buildNested(rest, children)}
        </ProviderComponent>
      );
    };

    return buildNested(
      providerTree.filter(Boolean).flatMap(p => [p, ...p.dependencies]),
      children
    );
  };

  return { registerProvider, buildProviderTree };
}

// Application-specific providers
const AppProviderRegistry = createProviderHierarchy();

// Core providers
function ConfigProvider({ children }) {
  const config = {
    apiUrl: process.env.REACT_APP_API_URL,
    environment: process.env.NODE_ENV,
    features: {
      audioRecording: true,
      analytics: process.env.NODE_ENV === 'production',
      advancedMetrics: false
    }
  };

  return (
    <ConfigContext.Provider value={config}>
      {children}
    </ConfigContext.Provider>
  );
}

function ApiProvider({ children }) {
  const config = useConfig();
  const api = useMemo(() => createApiClient(config.apiUrl), [config.apiUrl]);

  return (
    <ApiContext.Provider value={api}>
      {children}
    </ApiContext.Provider>
  );
}

function AuthProvider({ children }) {
  const api = useApi();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const authService = useMemo(() => ({
    login: async (credentials) => {
      const user = await api.login(credentials);
      setUser(user);
      return user;
    },
    logout: async () => {
      await api.logout();
      setUser(null);
    },
    getCurrentUser: () => user,
    isAuthenticated: () => !!user
  }), [api, user]);

  useEffect(() => {
    api.getCurrentUser()
      .then(setUser)
      .catch(() => setUser(null))
      .finally(() => setLoading(false));
  }, [api]);

  if (loading) return <div>Loading...</div>;

  return (
    <AuthContext.Provider value={authService}>
      {children}
    </AuthContext.Provider>
  );
}

function NotificationProvider({ children }) {
  const [notifications, setNotifications] = useState([]);

  const notificationService = useMemo(() => ({
    show: (message, type = 'info', duration = 5000) => {
      const id = Date.now();
      const notification = { id, message, type, duration };
      
      setNotifications(prev => [...prev, notification]);
      
      if (duration > 0) {
        setTimeout(() => {
          setNotifications(prev => prev.filter(n => n.id !== id));
        }, duration);
      }

      return id;
    },
    
    dismiss: (id) => {
      setNotifications(prev => prev.filter(n => n.id !== id));
    },
    
    clear: () => setNotifications([])
  }), []);

  return (
    <NotificationContext.Provider value={notificationService}>
      {children}
      <NotificationDisplay notifications={notifications} />
    </NotificationContext.Provider>
  );
}

// Feature-specific providers
function PracticeSessionProvider({ children }) {
  const api = useApi();
  const auth = useAuth();
  const notifications = useNotifications();
  
  const [activeSessions, setActiveSessions] = useState(new Map());
  const [sessionHistory, setSessionHistory] = useState([]);

  const sessionService = useMemo(() => ({
    createSession: async (sessionData) => {
      try {
        const session = await api.createSession({
          ...sessionData,
          userId: auth.getCurrentUser()?.id
        });
        
        setActiveSessions(prev => new Map(prev).set(session.id, session));
        notifications.show('Practice session created', 'success');
        
        return session;
      } catch (error) {
        notifications.show('Failed to create session', 'error');
        throw error;
      }
    },

    updateSession: async (sessionId, updates) => {
      try {
        const session = await api.updateSession(sessionId, updates);
        
        setActiveSessions(prev => {
          const newMap = new Map(prev);
          newMap.set(sessionId, session);
          return newMap;
        });

        return session;
      } catch (error) {
        notifications.show('Failed to update session', 'error');
        throw error;
      }
    },

    completeSession: async (sessionId) => {
      try {
        const session = await api.completeSession(sessionId);
        
        setActiveSessions(prev => {
          const newMap = new Map(prev);
          newMap.delete(sessionId);
          return newMap;
        });

        setSessionHistory(prev => [session, ...prev]);
        notifications.show('Session completed!', 'success');
        
        return session;
      } catch (error) {
        notifications.show('Failed to complete session', 'error');
        throw error;
      }
    },

    getActiveSession: (sessionId) => activeSessions.get(sessionId),
    getAllActiveSessions: () => Array.from(activeSessions.values()),
    getSessionHistory: () => sessionHistory
  }), [api, auth, notifications, activeSessions, sessionHistory]);

  return (
    <PracticeSessionContext.Provider value={sessionService}>
      {children}
    </PracticeSessionContext.Provider>
  );
}

// Register providers with dependencies
AppProviderRegistry.registerProvider('config', ConfigProvider);
AppProviderRegistry.registerProvider('api', ApiProvider, ['config']);
AppProviderRegistry.registerProvider('auth', AuthProvider, ['api']);
AppProviderRegistry.registerProvider('notifications', NotificationProvider);
AppProviderRegistry.registerProvider('practiceSession', PracticeSessionProvider, 
  ['api', 'auth', 'notifications']);

// Application root with selective provider loading
function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={
          <AppProviders providers={['config', 'api', 'notifications']}>
            <LoginPage />
          </AppProviders>
        } />
        
        <Route path="/practice/*" element={
          <AppProviders providers={['config', 'api', 'auth', 'notifications', 'practiceSession']}>
            <PracticeApp />
          </AppProviders>
        } />
        
        <Route path="/*" element={
          <AppProviders providers={['config', 'api', 'auth', 'notifications']}>
            <MainApp />
          </AppProviders>
        } />
      </Routes>
    </Router>
  );
}

function AppProviders({ providers, children }) {
  return AppProviderRegistry.buildProviderTree(providers, children);
}
```

:::

### Service container patterns {.unnumbered .unlisted}

Service containers provide a more sophisticated approach to dependency injection, allowing for lazy loading, service decoration, and complex service resolution patterns.

::: example

```jsx
// Advanced service container
class ServiceContainer {
  constructor() {
    this.services = new Map();
    this.factories = new Map();
    this.singletons = new Map();
    this.decorators = new Map();
  }

  // Register a service factory
  register(name, factory, options = {}) {
    const { singleton = false, dependencies = [] } = options;
    
    this.factories.set(name, {
      factory,
      dependencies,
      singleton
    });

    return this;
  }

  // Register a singleton service
  singleton(name, factory, dependencies = []) {
    return this.register(name, factory, { singleton: true, dependencies });
  }

  // Add a decorator to a service
  decorate(serviceName, decorator) {
    if (!this.decorators.has(serviceName)) {
      this.decorators.set(serviceName, []);
    }
    this.decorators.get(serviceName).push(decorator);
    return this;
  }

  // Resolve a service with its dependencies
  resolve(name) {
    // Check if already instantiated singleton
    if (this.singletons.has(name)) {
      return this.singletons.get(name);
    }

    // Check if service is registered
    if (!this.factories.has(name)) {
      throw new Error(`Service not registered: ${name}`);
    }

    const { factory, dependencies, singleton } = this.factories.get(name);

    // Resolve dependencies
    const resolvedDependencies = dependencies.map(dep => this.resolve(dep));

    // Create service instance
    let service = factory(...resolvedDependencies);

    // Apply decorators
    const decorators = this.decorators.get(name) || [];
    service = decorators.reduce((svc, decorator) => decorator(svc), service);

    // Store singleton
    if (singleton) {
      this.singletons.set(name, service);
    }

    return service;
  }

  // Check if service is registered
  has(name) {
    return this.factories.has(name);
  }

  // Clear all services (useful for testing)
  clear() {
    this.services.clear();
    this.factories.clear();
    this.singletons.clear();
    this.decorators.clear();
  }
}

// React hook for service container
function useServiceContainer() {
  const context = useContext(ServiceContainerContext);
  if (!context) {
    throw new Error('useServiceContainer must be used within ServiceContainerProvider');
  }
  return context;
}

function useService(serviceName) {
  const container = useServiceContainer();
  return useMemo(() => container.resolve(serviceName), [container, serviceName]);
}

// Service definitions for practice app
function setupPracticeServices(container) {
  // Core services
  container.singleton('logger', () => ({
    log: (message, level = 'info') => {
      console.log(`[${level.toUpperCase()}] ${message}`);
    },
    error: (message, error) => {
      console.error(`[ERROR] ${message}`, error);
    }
  }));

  container.singleton('eventBus', () => {
    const listeners = new Map();
    
    return {
      on: (event, callback) => {
        if (!listeners.has(event)) {
          listeners.set(event, []);
        }
        listeners.get(event).push(callback);
      },
      
      off: (event, callback) => {
        if (listeners.has(event)) {
          const callbacks = listeners.get(event);
          const index = callbacks.indexOf(callback);
          if (index > -1) {
            callbacks.splice(index, 1);
          }
        }
      },
      
      emit: (event, data) => {
        if (listeners.has(event)) {
          listeners.get(event).forEach(callback => callback(data));
        }
      }
    };
  });

  container.singleton('cache', () => {
    const cache = new Map();
    
    return {
      get: (key) => {
        const item = cache.get(key);
        if (!item) return null;
        
        if (Date.now() > item.expiry) {
          cache.delete(key);
          return null;
        }
        
        return item.value;
      },
      
      set: (key, value, ttl = 300000) => {
        cache.set(key, {
          value,
          expiry: Date.now() + ttl
        });
      },
      
      clear: () => cache.clear()
    };
  });

  // API services
  container.singleton('httpClient', (logger) => {
    return {
      get: async (url) => {
        logger.log(`GET ${url}`);
        const response = await fetch(url);
        return response.json();
      },
      
      post: async (url, data) => {
        logger.log(`POST ${url}`);
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });
        return response.json();
      }
    };
  }, ['logger']);

  container.register('apiClient', (httpClient, cache) => {
    return {
      getSessions: async (userId) => {
        const cacheKey = `sessions-${userId}`;
        let sessions = cache.get(cacheKey);
        
        if (!sessions) {
          sessions = await httpClient.get(`/api/users/${userId}/sessions`);
          cache.set(cacheKey, sessions, 60000); // 1 minute cache
        }
        
        return sessions;
      },
      
      createSession: async (sessionData) => {
        const session = await httpClient.post('/api/sessions', sessionData);
        
        // Invalidate cache
        cache.clear();
        
        return session;
      }
    };
  }, ['httpClient', 'cache']);

  // Analytics service with decorator pattern
  container.register('analytics', (logger, eventBus) => {
    return {
      track: (event, data) => {
        logger.log(`Analytics: ${event}`, data);
        eventBus.emit('analytics:track', { event, data });
      }
    };
  }, ['logger', 'eventBus']);

  // Add development decorator for analytics
  if (process.env.NODE_ENV === 'development') {
    container.decorate('analytics', (analytics) => ({
      ...analytics,
      track: (event, data) => {
        console.warn(`[DEV] Analytics tracking: ${event}`, data);
        return analytics.track(event, data);
      }
    }));
  }

  return container;
}

// Provider component
function ServiceContainerProvider({ children }) {
  const container = useMemo(() => {
    const serviceContainer = new ServiceContainer();
    return setupPracticeServices(serviceContainer);
  }, []);

  return (
    <ServiceContainerContext.Provider value={container}>
      {children}
    </ServiceContainerContext.Provider>
  );
}

// Usage in components
function PracticeSessionCard({ sessionId }) {
  const apiClient = useService('apiClient');
  const analytics = useService('analytics');
  
  const [session, setSession] = useState(null);

  useEffect(() => {
    apiClient.getSession(sessionId)
      .then(setSession)
      .catch(console.error);
      
    analytics.track('session_card_viewed', { sessionId });
  }, [sessionId, apiClient, analytics]);

  // Component implementation...
}
```

:::

### Testing strategies for provider-based architectures {.unnumbered .unlisted}

Provider patterns require sophisticated testing strategies to ensure proper isolation and behavior verification across different provider configurations.

::: example

```jsx
// Testing utilities for provider-based architecture
function createTestProviders() {
  const mockServices = new Map();
  
  // Create mock service factory
  const createMockService = (name, implementation = {}) => {
    const mock = {
      ...implementation,
      __isMock: true,
      __calls: []
    };

    // Wrap methods to track calls
    Object.keys(implementation).forEach(key => {
      if (typeof implementation[key] === 'function') {
        const originalMethod = implementation[key];
        mock[key] = (...args) => {
          mock.__calls.push({ method: key, args, timestamp: Date.now() });
          return originalMethod(...args);
        };
      }
    });

    mockServices.set(name, mock);
    return mock;
  };

  // Provider wrapper for tests
  const TestProviderWrapper = ({ services = {}, children }) => {
    const testContainer = useMemo(() => {
      const container = new ServiceContainer();
      
      // Register mock services
      Object.entries(services).forEach(([name, implementation]) => {
        const mockService = createMockService(name, implementation);
        container.singleton(name, () => mockService);
      });

      return container;
    }, [services]);

    return (
      <ServiceContainerContext.Provider value={testContainer}>
        {children}
      </ServiceContainerContext.Provider>
    );
  };

  return {
    TestProviderWrapper,
    getMockService: (name) => mockServices.get(name),
    getAllMocks: () => Array.from(mockServices.entries()),
    clearMocks: () => {
      mockServices.forEach(mock => {
        mock.__calls = [];
      });
    },
    resetMocks: () => {
      mockServices.clear();
    }
  };
}

// Test helper for React Testing Library
function renderWithProviders(component, options = {}) {
  const {
    services = {},
    providerProps = {},
    ...renderOptions
  } = options;

  const { TestProviderWrapper, ...testUtils } = createTestProviders();

  const wrapper = ({ children }) => (
    <TestProviderWrapper services={services} {...providerProps}>
      {children}
    </TestProviderWrapper>
  );

  return {
    ...render(component, { wrapper, ...renderOptions }),
    ...testUtils
  };
}

// Example tests
describe('PracticeSessionCard', () => {
  it('loads and displays session data', async () => {
    const mockSession = {
      id: '123',
      title: 'Bach Invention No. 1',
      duration: 1800,
      date: '2023-06-24'
    };

    const mockApiClient = {
      getSession: jest.fn().mockResolvedValue(mockSession)
    };

    const mockAnalytics = {
      track: jest.fn()
    };

    const { getByText, getMockService } = renderWithProviders(
      <PracticeSessionCard sessionId="123" />,
      {
        services: {
          apiClient: mockApiClient,
          analytics: mockAnalytics
        }
      }
    );

    // Wait for component to load
    await waitFor(() => {
      expect(getByText('Bach Invention No. 1')).toBeInTheDocument();
    });

    // Verify API call
    const apiMock = getMockService('apiClient');
    expect(apiMock.__calls).toHaveLength(1);
    expect(apiMock.__calls[0]).toEqual({
      method: 'getSession',
      args: ['123'],
      timestamp: expect.any(Number)
    });

    // Verify analytics tracking
    const analyticsMock = getMockService('analytics');
    expect(analyticsMock.__calls).toContainEqual({
      method: 'track',
      args: ['session_card_viewed', { sessionId: '123' }],
      timestamp: expect.any(Number)
    });
  });

  it('handles API errors gracefully', async () => {
    const mockApiClient = {
      getSession: jest.fn().mockRejectedValue(new Error('Network error'))
    };

    const { getByText } = renderWithProviders(
      <PracticeSessionCard sessionId="123" />,
      {
        services: {
          apiClient: mockApiClient,
          analytics: { track: jest.fn() }
        }
      }
    );

    await waitFor(() => {
      expect(getByText(/error loading session/i)).toBeInTheDocument();
    });
  });
});

// Integration tests for provider hierarchy
describe('Provider Integration', () => {
  it('resolves service dependencies correctly', () => {
    const services = {};
    
    const { TestProviderWrapper } = createTestProviders();
    
    render(
      <TestProviderWrapper services={services}>
        <TestComponent />
      </TestProviderWrapper>
    );

    // Test service resolution and dependency injection
  });

  it('handles circular dependencies', () => {
    expect(() => {
      const container = new ServiceContainer();
      container.register('serviceA', (serviceB) => ({ name: 'A' }), ['serviceB']);
      container.register('serviceB', (serviceA) => ({ name: 'B' }), ['serviceA']);
      container.resolve('serviceA');
    }).toThrow('Circular dependency detected');
  });
});
```

:::

### Performance optimization for provider architectures {.unnumbered .unlisted}

Provider-based architectures can suffer from performance issues if not properly optimized. This section covers strategies for minimizing re-renders and optimizing provider updates.

::: example

```jsx
// Optimized provider with selective updates
function createOptimizedProvider(name, initialState, reducers) {
  const StateContext = createContext();
  const DispatchContext = createContext();
  const SelectorsContext = createContext();

  function ProviderComponent({ children }) {
    const [state, dispatch] = useReducer(
      (state, action) => {
        const reducer = reducers[action.type];
        return reducer ? reducer(state, action.payload) : state;
      },
      initialState
    );

    // Memoized dispatch to prevent unnecessary re-renders
    const memoizedDispatch = useCallback(dispatch, []);

    // Create selectors for optimized state access
    const selectors = useMemo(() => {
      const selectorCache = new Map();
      
      return {
        // Create a memoized selector
        create: (selector) => {
          const key = selector.toString();
          
          if (!selectorCache.has(key)) {
            let lastResult = undefined;
            let lastState = undefined;
            
            const memoizedSelector = (currentState) => {
              if (currentState === lastState) {
                return lastResult;
              }
              
              lastState = currentState;
              lastResult = selector(currentState);
              return lastResult;
            };
            
            selectorCache.set(key, memoizedSelector);
          }
          
          return selectorCache.get(key);
        },
        
        // Pre-built common selectors
        all: () => state,
        byId: (id) => state.items?.[id],
        list: () => Object.values(state.items || {}),
        count: () => Object.keys(state.items || {}).length
      };
    }, [state]);

    return (
      <StateContext.Provider value={state}>
        <DispatchContext.Provider value={memoizedDispatch}>
          <SelectorsContext.Provider value={selectors}>
            {children}
          </SelectorsContext.Provider>
        </DispatchContext.Provider>
      </StateContext.Provider>
    );
  }

  // Hooks for consuming the provider
  const useState = () => {
    const context = useContext(StateContext);
    if (context === undefined) {
      throw new Error(`use${name}State must be used within ${name}Provider`);
    }
    return context;
  };

  const useDispatch = () => {
    const context = useContext(DispatchContext);
    if (context === undefined) {
      throw new Error(`use${name}Dispatch must be used within ${name}Provider`);
    }
    return context;
  };

  const useSelectors = () => {
    const context = useContext(SelectorsContext);
    if (context === undefined) {
      throw new Error(`use${name}Selectors must be used within ${name}Provider`);
    }
    return context;
  };

  // Optimized selector hook
  const useSelector = (selector) => {
    const state = useState();
    const selectors = useSelectors();
    
    const memoizedSelector = useMemo(() => 
      selectors.create(selector), [selector, selectors]);
    
    return useMemo(() => 
      memoizedSelector(state), [memoizedSelector, state]);
  };

  return {
    Provider: ProviderComponent,
    useState,
    useDispatch,
    useSelector,
    useSelectors
  };
}

// Practice sessions provider with optimizations
const practiceSessionsReducers = {
  ADD_SESSION: (state, session) => ({
    ...state,
    items: {
      ...state.items,
      [session.id]: session
    },
    activeSession: session.id
  }),

  UPDATE_SESSION: (state, { id, updates }) => ({
    ...state,
    items: {
      ...state.items,
      [id]: { ...state.items[id], ...updates }
    }
  }),

  REMOVE_SESSION: (state, sessionId) => {
    const { [sessionId]: removed, ...remainingItems } = state.items;
    return {
      ...state,
      items: remainingItems,
      activeSession: state.activeSession === sessionId ? null : state.activeSession
    };
  },

  SET_ACTIVE_SESSION: (state, sessionId) => ({
    ...state,
    activeSession: sessionId
  })
};

const {
  Provider: PracticeSessionProvider,
  useSelector: usePracticeSessionSelector,
  useDispatch: usePracticeSessionDispatch
} = createOptimizedProvider(
  'PracticeSession',
  { items: {}, activeSession: null },
  practiceSessionsReducers
);

// Usage with optimized selectors
function SessionsList() {
  // Only re-renders when the sessions list changes
  const sessions = usePracticeSessionSelector(state => 
    Object.values(state.items)
  );
  
  const dispatch = usePracticeSessionDispatch();

  const handleDeleteSession = useCallback((sessionId) => {
    dispatch({ type: 'REMOVE_SESSION', payload: sessionId });
  }, [dispatch]);

  return (
    <div>
      {sessions.map(session => (
        <SessionItem 
          key={session.id} 
          sessionId={session.id}
          onDelete={handleDeleteSession}
        />
      ))}
    </div>
  );
}

function SessionItem({ sessionId, onDelete }) {
  // Only re-renders when this specific session changes
  const session = usePracticeSessionSelector(state => 
    state.items[sessionId]
  );

  const handleDelete = useCallback(() => {
    onDelete(sessionId);
  }, [sessionId, onDelete]);

  if (!session) return null;

  return (
    <div className="session-item">
      <h3>{session.title}</h3>
      <p>Duration: {session.duration}s</p>
      <button onClick={handleDelete}>Delete</button>
    </div>
  );
}

// Performance monitoring hook
function useProviderPerformance(providerName) {
  const renderCount = useRef(0);
  const lastRenderTime = useRef(Date.now());

  useEffect(() => {
    renderCount.current++;
    const now = Date.now();
    const timeSinceLastRender = now - lastRenderTime.current;
    
    if (process.env.NODE_ENV === 'development') {
      console.log(`${providerName} render #${renderCount.current}, time since last: ${timeSinceLastRender}ms`);
    }
    
    lastRenderTime.current = now;
  });

  return {
    renderCount: renderCount.current,
    timeSinceLastRender: Date.now() - lastRenderTime.current
  };
}
```

:::

Provider patterns and dependency injection create powerful architectural foundations for React applications. When implemented with careful attention to performance and testing, these patterns can eliminate the need for external state management libraries while providing superior modularity, testability, and maintainability. The key is to balance the flexibility of the provider pattern with the performance requirements of your specific application.

::: important
**Provider patterns as architectural foundation**

Well-designed provider patterns serve as the architectural backbone of large React applications. They enable loose coupling between components and services, facilitate testing through dependency injection, and provide clear contracts for cross-cutting concerns like data access, authentication, and business logic.
:::

### Hierarchical provider composition {.unnumbered .unlisted}

Complex applications often need multiple levels of providers that compose together to provide different services at different levels of the component tree.

::: example

```jsx
// Base provider for application-wide services
function ApplicationProvider({ children, config }) {
  const [api] = useState(() => new ApiClient(config.apiUrl));
  const [analytics] = useState(() => new AnalyticsService(config.analyticsKey));
  const [notifications] = useState(() => new NotificationService());

  const services = useMemo(() => ({
    api,
    analytics,
    notifications,
    config
  }), [api, analytics, notifications, config]);

  return (
    <ApplicationContext.Provider value={services}>
      {children}
    </ApplicationContext.Provider>
  );
}

// User session provider that depends on application services
function UserSessionProvider({ children }) {
  const { api, analytics } = useApplicationServices();
  const [user, setUser] = useState(null);
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);

  // Authentication logic
  const login = useCallback(async (credentials) => {
    try {
      const response = await api.login(credentials);
      setUser(response.user);
      setSession(response.session);
      analytics.track('user_login', { userId: response.user.id });
      return response;
    } catch (error) {
      analytics.track('login_failed', { error: error.message });
      throw error;
    }
  }, [api, analytics]);

  const logout = useCallback(async () => {
    if (session) {
      await api.logout(session.token);
      analytics.track('user_logout', { userId: user?.id });
    }
    setUser(null);
    setSession(null);
  }, [api, analytics, session, user]);

  // Session management
  useEffect(() => {
    const initializeSession = async () => {
      try {
        const storedSession = localStorage.getItem('user_session');
        if (storedSession) {
          const sessionData = JSON.parse(storedSession);
          const validatedSession = await api.validateSession(sessionData.token);
          setUser(validatedSession.user);
          setSession(validatedSession.session);
        }
      } catch (error) {
        localStorage.removeItem('user_session');
      } finally {
        setLoading(false);
      }
    };

    initializeSession();
  }, [api]);

  // Persist session changes
  useEffect(() => {
    if (session) {
      localStorage.setItem('user_session', JSON.stringify(session));
    } else {
      localStorage.removeItem('user_session');
    }
  }, [session]);

  const sessionValue = useMemo(() => ({
    user,
    session,
    loading,
    isAuthenticated: !!user,
    login,
    logout
  }), [user, session, loading, login, logout]);

  return (
    <UserSessionContext.Provider value={sessionValue}>
      {children}
    </UserSessionContext.Provider>
  );
}

// Feature-specific provider for practice sessions
function PracticeSessionProvider({ children }) {
  const { api, analytics } = useApplicationServices();
  const { user } = useUserSession();
  
  const [activeSessions, setActiveSessions] = useState([]);
  const [sessionHistory, setSessionHistory] = useState([]);
  const [loading, setLoading] = useState(false);

  // Session management
  const createSession = useCallback(async (sessionData) => {
    setLoading(true);
    try {
      const session = await api.createPracticeSession({
        ...sessionData,
        userId: user.id
      });
      
      setActiveSessions(prev => [...prev, session]);
      analytics.track('practice_session_created', {
        sessionId: session.id,
        pieceId: session.pieceId,
        userId: user.id
      });
      
      return session;
    } finally {
      setLoading(false);
    }
  }, [api, analytics, user?.id]);

  const completeSession = useCallback(async (sessionId, completionData) => {
    setLoading(true);
    try {
      const completedSession = await api.completePracticeSession(sessionId, completionData);
      
      setActiveSessions(prev => prev.filter(s => s.id !== sessionId));
      setSessionHistory(prev => [completedSession, ...prev]);
      
      analytics.track('practice_session_completed', {
        sessionId,
        duration: completionData.duration,
        userId: user.id
      });
      
      return completedSession;
    } finally {
      setLoading(false);
    }
  }, [api, analytics, user?.id]);

  // Load user's session data
  useEffect(() => {
    if (!user) return;

    const loadSessions = async () => {
      setLoading(true);
      try {
        const [active, history] = await Promise.all([
          api.getActivePracticeSessions(user.id),
          api.getPracticeSessionHistory(user.id)
        ]);
        
        setActiveSessions(active);
        setSessionHistory(history);
      } catch (error) {
        console.error('Failed to load practice sessions:', error);
      } finally {
        setLoading(false);
      }
    };

    loadSessions();
  }, [user, api]);

  const practiceValue = useMemo(() => ({
    activeSessions,
    sessionHistory,
    loading,
    createSession,
    completeSession
  }), [activeSessions, sessionHistory, loading, createSession, completeSession]);

  return (
    <PracticeSessionContext.Provider value={practiceValue}>
      {children}
    </PracticeSessionContext.Provider>
  );
}

// Composed provider hierarchy
function AppProviders({ children, config }) {
  return (
    <ApplicationProvider config={config}>
      <UserSessionProvider>
        <PracticeSessionProvider>
          {children}
        </PracticeSessionProvider>
      </UserSessionProvider>
    </ApplicationProvider>
  );
}
```

:::

### Service container patterns {.unnumbered .unlisted}

Service containers provide a more sophisticated approach to dependency injection, allowing for lazy loading, service decoration, and dynamic service resolution.

::: example

```jsx
// Service container implementation
class ServiceContainer {
  constructor() {
    this.services = new Map();
    this.factories = new Map();
    this.instances = new Map();
    this.decorators = new Map();
  }

  // Register a service factory
  register(name, factory, options = {}) {
    const { singleton = true, dependencies = [] } = options;
    
    this.factories.set(name, {
      factory,
      singleton,
      dependencies
    });
    
    return this;
  }

  // Register a service instance
  instance(name, service) {
    this.instances.set(name, service);
    return this;
  }

  // Add decorator for a service
  decorate(name, decorator) {
    if (!this.decorators.has(name)) {
      this.decorators.set(name, []);
    }
    this.decorators.get(name).push(decorator);
    return this;
  }

  // Resolve a service
  resolve(name) {
    // Check for existing instance
    if (this.instances.has(name)) {
      return this.instances.get(name);
    }

    // Check for singleton instance
    if (this.services.has(name)) {
      return this.services.get(name);
    }

    // Get factory
    const factory = this.factories.get(name);
    if (!factory) {
      throw new Error(`Service '${name}' not registered`);
    }

    // Resolve dependencies
    const dependencies = factory.dependencies.map(dep => this.resolve(dep));
    
    // Create instance
    let instance = factory.factory(...dependencies);
    
    // Apply decorators
    const decorators = this.decorators.get(name) || [];
    instance = decorators.reduce((service, decorator) => decorator(service), instance);
    
    // Store singleton
    if (factory.singleton) {
      this.services.set(name, instance);
    }
    
    return instance;
  }

  // Check if service is registered
  has(name) {
    return this.factories.has(name) || this.instances.has(name);
  }

  // Create child container
  createScope() {
    const child = new ServiceContainer();
    child.parent = this;
    
    // Override resolve to check parent
    const originalResolve = child.resolve.bind(child);
    child.resolve = (name) => {
      try {
        return originalResolve(name);
      } catch (error) {
        if (this.has(name)) {
          return this.resolve(name);
        }
        throw error;
      }
    };
    
    return child;
  }
}

// Service container provider
function ServiceContainerProvider({ children, container = null }) {
  const [serviceContainer] = useState(() => {
    if (container) return container;
    
    // Create and configure default container
    const defaultContainer = new ServiceContainer();
    
    // Register core services
    defaultContainer
      .register('config', () => ({
        apiUrl: process.env.REACT_APP_API_URL,
        analyticsKey: process.env.REACT_APP_ANALYTICS_KEY
      }))
      .register('httpClient', (config) => new HttpClient(config.apiUrl), {
        dependencies: ['config']
      })
      .register('apiClient', (httpClient) => new ApiClient(httpClient), {
        dependencies: ['httpClient']
      })
      .register('analyticsService', (config) => new AnalyticsService(config.analyticsKey), {
        dependencies: ['config']
      })
      .register('notificationService', () => new NotificationService())
      .register('practiceSessionService', (apiClient, analytics) => 
        new PracticeSessionService(apiClient, analytics), {
        dependencies: ['apiClient', 'analyticsService']
      });
    
    return defaultContainer;
  });

  return (
    <ServiceContainerContext.Provider value={serviceContainer}>
      {children}
    </ServiceContainerContext.Provider>
  );
}

// Hook to access services
function useService(serviceName) {
  const container = useContext(ServiceContainerContext);
  if (!container) {
    throw new Error('useService must be used within ServiceContainerProvider');
  }
  
  return useMemo(() => container.resolve(serviceName), [container, serviceName]);
}

// Hook to access multiple services
function useServices(...serviceNames) {
  const container = useContext(ServiceContainerContext);
  if (!container) {
    throw new Error('useServices must be used within ServiceContainerProvider');
  }
  
  return useMemo(() => {
    const services = {};
    serviceNames.forEach(name => {
      services[name] = container.resolve(name);
    });
    return services;
  }, [container, serviceNames]);
}

// Usage in components
function PracticeSessionForm({ onSubmit }) {
  const practiceService = useService('practiceSessionService');
  const { user } = useUserSession();
  
  const [formData, setFormData] = useState({
    pieceId: '',
    duration: 30,
    goals: []
  });
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const session = await practiceService.createSession({
        ...formData,
        userId: user.id
      });
      onSubmit(session);
    } catch (error) {
      console.error('Failed to create session:', error);
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      {/* Form implementation */}
    </form>
  );
}

// Service decoration example
function withLogging(service) {
  return new Proxy(service, {
    get(target, prop) {
      const value = target[prop];
      if (typeof value === 'function') {
        return function(...args) {
          console.log(`Calling ${prop} with`, args);
          const result = value.apply(target, args);
          if (result instanceof Promise) {
            return result.then(res => {
              console.log(`${prop} resolved with`, res);
              return res;
            }).catch(err => {
              console.error(`${prop} rejected with`, err);
              throw err;
            });
          }
          console.log(`${prop} returned`, result);
          return result;
        };
      }
      return value;
    }
  });
}

// Add logging decoration
serviceContainer.decorate('practiceSessionService', withLogging);
```

:::

### Testing with provider patterns {.unnumbered .unlisted}

Provider patterns greatly enhance testability by enabling easy mocking and service substitution during testing.

::: example

```jsx
// Test utilities for provider patterns
function createTestServiceContainer() {
  const container = new ServiceContainer();
  
  // Register mock services
  container
    .instance('config', {
      apiUrl: 'http://localhost:3001',
      analyticsKey: 'test-key'
    })
    .instance('apiClient', {
      createPracticeSession: jest.fn(),
      getPracticeSession: jest.fn(),
      updatePracticeSession: jest.fn(),
      deletePracticeSession: jest.fn()
    })
    .instance('analyticsService', {
      track: jest.fn(),
      identify: jest.fn()
    })
    .instance('notificationService', {
      show: jest.fn(),
      hide: jest.fn()
    });
  
  return container;
}

// Test wrapper component
function TestProviders({ children, container, user = null }) {
  const testContainer = container || createTestServiceContainer();
  
  const mockUserSession = {
    user,
    session: user ? { token: 'test-token', id: 'test-session' } : null,
    loading: false,
    isAuthenticated: !!user,
    login: jest.fn(),
    logout: jest.fn()
  };
  
  return (
    <ServiceContainerProvider container={testContainer}>
      <UserSessionContext.Provider value={mockUserSession}>
        <PracticeSessionProvider>
          {children}
        </PracticeSessionProvider>
      </UserSessionContext.Provider>
    </ServiceContainerProvider>
  );
}

// Test example
describe('PracticeSessionForm', () => {
  let mockApiClient;
  let mockAnalytics;
  
  beforeEach(() => {
    const container = createTestServiceContainer();
    mockApiClient = container.resolve('apiClient');
    mockAnalytics = container.resolve('analyticsService');
  });
  
  it('creates a practice session', async () => {
    const mockUser = { id: 'user-1', name: 'Test User' };
    const mockSession = { id: 'session-1', pieceId: 'piece-1' };
    
    mockApiClient.createPracticeSession.mockResolvedValue(mockSession);
    
    const onSubmit = jest.fn();
    
    render(
      <TestProviders user={mockUser}>
        <PracticeSessionForm onSubmit={onSubmit} />
      </TestProviders>
    );
    
    // Fill form
    fireEvent.change(screen.getByLabelText(/piece/i), {
      target: { value: 'piece-1' }
    });
    
    fireEvent.change(screen.getByLabelText(/duration/i), {
      target: { value: '45' }
    });
    
    // Submit form
    fireEvent.click(screen.getByRole('button', { name: /start session/i }));
    
    await waitFor(() => {
      expect(mockApiClient.createPracticeSession).toHaveBeenCalledWith({
        pieceId: 'piece-1',
        duration: 45,
        goals: [],
        userId: 'user-1'
      });
    });
    
    expect(onSubmit).toHaveBeenCalledWith(mockSession);
  });
  
  it('handles creation errors', async () => {
    const mockUser = { id: 'user-1', name: 'Test User' };
    const error = new Error('Network error');
    
    mockApiClient.createPracticeSession.mockRejectedValue(error);
    
    render(
      <TestProviders user={mockUser}>
        <PracticeSessionForm onSubmit={jest.fn()} />
      </TestProviders>
    );
    
    // Submit form
    fireEvent.click(screen.getByRole('button', { name: /start session/i }));
    
    await waitFor(() => {
      expect(screen.getByText(/failed to create session/i)).toBeInTheDocument();
    });
  });
});

// Integration test with real services
describe('Practice Session Integration', () => {
  let testServer;
  
  beforeAll(() => {
    testServer = setupTestServer();
  });
  
  afterAll(() => {
    testServer.close();
  });
  
  it('creates and manages practice sessions end-to-end', async () => {
    const container = new ServiceContainer();
    
    // Register real services pointing to test server
    container
      .instance('config', {
        apiUrl: testServer.url,
        analyticsKey: 'test-key'
      })
      .register('httpClient', (config) => new HttpClient(config.apiUrl), {
        dependencies: ['config']
      })
      .register('apiClient', (httpClient) => new ApiClient(httpClient), {
        dependencies: ['httpClient']
      });
    
    const mockUser = { id: 'user-1', name: 'Test User' };
    
    render(
      <TestProviders container={container} user={mockUser}>
        <PracticeSessionDashboard />
      </TestProviders>
    );
    
    // Test complete user flow
    // Create session
    fireEvent.click(screen.getByRole('button', { name: /new session/i }));
    
    // Fill and submit form
    fireEvent.change(screen.getByLabelText(/piece/i), {
      target: { value: 'Bach Invention No. 1' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /start session/i }));
    
    // Verify session appears in list
    await waitFor(() => {
      expect(screen.getByText('Bach Invention No. 1')).toBeInTheDocument();
    });
    
    // Complete session
    fireEvent.click(screen.getByRole('button', { name: /complete/i }));
    
    // Verify session moves to history
    await waitFor(() => {
      expect(screen.getByText(/session completed/i)).toBeInTheDocument();
    });
  });
});
```

:::

### Performance optimization in provider patterns {.unnumbered .unlisted}

Provider patterns can impact performance if not implemented carefully. Here are strategies for optimizing provider-based architectures.

::: example

```jsx
// Optimized provider with selective context splitting
function OptimizedUserProvider({ children }) {
  const { api } = useApplicationServices();
  
  // Split frequently changing data from stable data
  const [userProfile, setUserProfile] = useState(null);
  const [userPreferences, setUserPreferences] = useState(null);
  const [authState, setAuthState] = useState({ loading: true, token: null });
  
  // Stable authentication methods
  const authMethods = useMemo(() => ({
    login: async (credentials) => {
      const response = await api.login(credentials);
      setAuthState({ loading: false, token: response.token });
      setUserProfile(response.user);
      return response;
    },
    
    logout: async () => {
      await api.logout();
      setAuthState({ loading: false, token: null });
      setUserProfile(null);
      setUserPreferences(null);
    }
  }), [api]);
  
  // Stable user profile context value
  const profileValue = useMemo(() => ({
    user: userProfile,
    updateProfile: setUserProfile
  }), [userProfile]);
  
  // Stable preferences context value
  const preferencesValue = useMemo(() => ({
    preferences: userPreferences,
    updatePreferences: setUserPreferences
  }), [userPreferences]);
  
  // Frequently changing auth state context value
  const authValue = useMemo(() => ({
    ...authState,
    isAuthenticated: !!authState.token,
    ...authMethods
  }), [authState, authMethods]);
  
  return (
    <UserAuthContext.Provider value={authValue}>
      <UserProfileContext.Provider value={profileValue}>
        <UserPreferencesContext.Provider value={preferencesValue}>
          {children}
        </UserPreferencesContext.Provider>
      </UserProfileContext.Provider>
    </UserAuthContext.Provider>
  );
}

// Selective context consumers
function useUserAuth() {
  const context = useContext(UserAuthContext);
  if (!context) {
    throw new Error('useUserAuth must be used within UserProvider');
  }
  return context;
}

function useUserProfile() {
  const context = useContext(UserProfileContext);
  if (!context) {
    throw new Error('useUserProfile must be used within UserProvider');
  }
  return context;
}

function useUserPreferences() {
  const context = useContext(UserPreferencesContext);
  if (!context) {
    throw new Error('useUserPreferences must be used within UserProvider');
  }
  return context;
}

// Context selector hook for fine-grained subscriptions
function createContextSelector(Context) {
  return function useContextSelector(selector) {
    const context = useContext(Context);
    if (!context) {
      throw new Error('useContextSelector must be used within provider');
    }
    
    const [, forceUpdate] = useReducer(c => c + 1, 0);
    const selectorRef = useRef(selector);
    const selectedValueRef = useRef();
    
    // Update selector
    selectorRef.current = selector;
    
    // Calculate selected value
    const selectedValue = selector(context);
    
    // Check if value changed
    useLayoutEffect(() => {
      if (!Object.is(selectedValueRef.current, selectedValue)) {
        selectedValueRef.current = selectedValue;
      }
    });
    
    // Force update when context changes
    useLayoutEffect(() => {
      let didChange = false;
      
      const checkForUpdates = () => {
        const newValue = selectorRef.current(context);
        if (!Object.is(selectedValueRef.current, newValue)) {
          selectedValueRef.current = newValue;
          didChange = true;
        }
      };
      
      checkForUpdates();
      
      if (didChange) {
        forceUpdate();
      }
    }, [context]);
    
    return selectedValue;
  };
}

// Usage with selectors
const useUserName = createContextSelector(UserProfileContext);
const useUserEmail = createContextSelector(UserProfileContext);

function UserGreeting() {
  // Only re-renders when user name changes
  const userName = useUserName(state => state.user?.name);
  
  return <div>Hello, {userName}!</div>;
}

function UserEmail() {
  // Only re-renders when user email changes
  const userEmail = useUserEmail(state => state.user?.email);
  
  return <div>Email: {userEmail}</div>;
}

// Provider composition with error boundaries
function RobustProviderComposition({ children }) {
  return (
    <ErrorBoundary fallback={<ApplicationErrorFallback />}>
      <ApplicationProvider>
        <ErrorBoundary fallback={<AuthErrorFallback />}>
          <OptimizedUserProvider>
            <ErrorBoundary fallback={<FeatureErrorFallback />}>
              <PracticeSessionProvider>
                {children}
              </PracticeSessionProvider>
            </ErrorBoundary>
          </OptimizedUserProvider>
        </ErrorBoundary>
      </ApplicationProvider>
    </ErrorBoundary>
  );
}
```

:::

Provider patterns and dependency injection create powerful architectural foundations for React applications. When implemented thoughtfully with performance considerations and proper testing strategies, they enable scalable, maintainable, and testable application architectures that can grow with your needs.

## Error boundaries and error handling patterns

Let's talk about one of React's more serious patterns: error boundaries. This isn't the most exciting topic, I'll admit, but hear me out-good error handling is what separates professional applications from hobby projects. And more importantly, it's what keeps your users happy when things inevitably go wrong.

I used to be terrible at error handling. My attitude was basically "write good code and errors won't happen." Then I shipped a music practice app to real users, and discovered that the universe has a very creative sense of humor when it comes to breaking your carefully crafted code. Network timeouts, browser quirks, users clicking buttons faster than humanly possible-you name it, they found it.

Error boundaries are React's way of saying "hey, when stuff breaks (and it will), let's handle it gracefully instead of showing users a blank white screen." But basic error boundaries are just the beginning. Advanced error handling patterns can turn potential disasters into minor inconveniences, and sometimes even improve the user experience.

Modern React applications require sophisticated error handling strategies that can gracefully degrade functionality, provide meaningful feedback to users, and maintain application stability even when individual features fail. Advanced error handling patterns combine error boundaries with context providers, custom hooks, and monitoring systems to create robust error management architectures.

::: important
**Building resilient user experiences**

Advanced error handling is not just about catching errors-it's about creating graceful degradation strategies that maintain user flow and provide actionable feedback. Well-designed error handling patterns can turn potential application crashes into opportunities for improved user experience and system reliability.
:::

### Advanced error boundary implementations {.unnumbered .unlisted}

Modern error boundaries go beyond simple try-catch wrappers to provide comprehensive error management with retry logic, fallback strategies, and error reporting capabilities.

::: example

```jsx
// Advanced error boundary with retry and fallback strategies
class AdvancedErrorBoundary extends Component {
  constructor(props) {
    super(props);
    
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      retryCount: 0,
      errorId: null
    };

    this.retryTimeouts = new Set();
  }

  static getDerivedStateFromError(error) {
    // Basic error state update
    return {
      hasError: true,
      error,
      errorId: `error_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    };
  }

  componentDidCatch(error, errorInfo) {
    const { onError, maxRetries = 3, retryDelay = 1000 } = this.props;
    
    // Enhanced error state with detailed information
    this.setState({
      error,
      errorInfo,
      retryCount: this.state.retryCount + 1
    });

    // Report error to monitoring service
    this.reportError(error, errorInfo);

    // Call custom error handler
    if (onError) {
      onError(error, errorInfo, {
        retryCount: this.state.retryCount,
        canRetry: this.state.retryCount < maxRetries
      });
    }

    // Auto-retry logic for recoverable errors
    if (this.isRecoverableError(error) && this.state.retryCount < maxRetries) {
      const timeout = setTimeout(() => {
        this.retry();
      }, retryDelay * Math.pow(2, this.state.retryCount)); // Exponential backoff

      this.retryTimeouts.add(timeout);
    }
  }

  componentWillUnmount() {
    // Clean up retry timeouts
    this.retryTimeouts.forEach(timeout => clearTimeout(timeout));
  }

  isRecoverableError = (error) => {
    // Define which errors are recoverable
    const recoverableErrors = [
      'ChunkLoadError', // Code splitting errors
      'NetworkError',   // Network-related errors
      'TimeoutError'    // Request timeout errors
    ];

    return recoverableErrors.some(errorType => 
      error.name === errorType || error.message.includes(errorType)
    );
  };

  reportError = async (error, errorInfo) => {
    const { errorReporting } = this.props;
    
    if (!errorReporting) return;

    try {
      const errorReport = {
        id: this.state.errorId,
        message: error.message,
        stack: error.stack,
        componentStack: errorInfo.componentStack,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        url: window.location.href,
        userId: this.props.userId,
        buildVersion: process.env.REACT_APP_VERSION,
        retryCount: this.state.retryCount,
        additionalContext: {
          props: this.props.errorContext,
          state: this.state
        }
      };

      await errorReporting.report(errorReport);
    } catch (reportingError) {
      console.error('Failed to report error:', reportingError);
    }
  };

  retry = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
      errorId: null
    });
  };

  render() {
    if (this.state.hasError) {
      const { fallback: Fallback, children } = this.props;
      const { error, retryCount, maxRetries = 3 } = this.props;

      // Custom fallback component
      if (Fallback) {
        return (
          <Fallback
            error={this.state.error}
            errorInfo={this.state.errorInfo}
            retry={this.retry}
            canRetry={retryCount < maxRetries}
            retryCount={retryCount}
          />
        );
      }

      // Default fallback UI
      return (
        <ErrorFallback
          error={this.state.error}
          retry={this.retry}
          canRetry={retryCount < maxRetries}
          retryCount={retryCount}
        />
      );
    }

    return this.props.children;
  }
}

// Enhanced fallback component
function ErrorFallback({ 
  error, 
  retry, 
  canRetry, 
  retryCount,
  title = "Something went wrong",
  showDetails = false 
}) {
  const [showErrorDetails, setShowErrorDetails] = useState(showDetails);

  return (
    <div className="error-boundary-fallback">
      <div className="error-content">
        <div className="error-icon">[!]</div>
        <h2>{title}</h2>
        <p>We're sorry, but something unexpected happened.</p>
        
        {retryCount > 0 && (
          <p className="retry-info">
            Retry attempts: {retryCount}
          </p>
        )}

        <div className="error-actions">
          {canRetry && (
            <button 
              onClick={retry}
              className="retry-button"
            >
              Try Again
            </button>
          )}
          
          <button 
            onClick={() => window.location.reload()}
            className="reload-button"
          >
            Reload Page
          </button>

          <button
            onClick={() => setShowErrorDetails(!showErrorDetails)}
            className="details-button"
          >
            {showErrorDetails ? 'Hide' : 'Show'} Details
          </button>
        </div>

        {showErrorDetails && (
          <details className="error-details">
            <summary>Technical Details</summary>
            <pre className="error-stack">
              {error.stack}
            </pre>
          </details>
        )}
      </div>
    </div>
  );
}

// Hook for programmatic error boundary usage
function useErrorBoundary() {
  const [error, setError] = useState(null);

  const resetError = useCallback(() => {
    setError(null);
  }, []);

  const captureError = useCallback((error) => {
    setError(error);
  }, []);

  useEffect(() => {
    if (error) {
      throw error;
    }
  }, [error]);

  return { captureError, resetError };
}

// Practice app error boundary configuration
function PracticeErrorBoundary({ children, feature }) {
  const errorReporting = useService('errorReporting');
  const auth = useAuth();

  return (
    <AdvancedErrorBoundary
      onError={(error, errorInfo, context) => {
        console.error(`Error in ${feature}:`, error, context);
      }}
      errorReporting={errorReporting}
      userId={auth.getCurrentUser()?.id}
      errorContext={{ feature }}
      maxRetries={3}
      retryDelay={1000}
      fallback={({ error, retry, canRetry, retryCount }) => (
        <div className="practice-error-fallback">
          <h3>Practice Feature Unavailable</h3>
          <p>
            The {feature} feature is temporarily unavailable. 
            {canRetry ? ' We\'ll try to restore it automatically.' : ''}
          </p>
          {canRetry && (
            <button onClick={retry}>
              Retry Now ({retryCount}/3)
            </button>
          )}
        </div>
      )}
    >
      {children}
    </AdvancedErrorBoundary>
  );
}
```

:::

### Context-based error management {.unnumbered .unlisted}

Context patterns can create application-wide error management systems that coordinate error handling across different features and provide centralized error reporting and recovery.

::: example

```jsx
// Global error management context
const ErrorManagementContext = createContext();

function ErrorManagementProvider({ children }) {
  const [errors, setErrors] = useState(new Map());
  const [globalErrorState, setGlobalErrorState] = useState('healthy');
  
  // Error categorization and priority
  const errorCategories = {
    CRITICAL: { priority: 1, color: 'red', autoRetry: false },
    HIGH: { priority: 2, color: 'orange', autoRetry: true },
    MEDIUM: { priority: 3, color: 'yellow', autoRetry: true },
    LOW: { priority: 4, color: 'blue', autoRetry: true }
  };

  const errorManager = useMemo(() => ({
    // Register an error with context
    reportError: (error, context = {}) => {
      const errorId = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const severity = classifyError(error);
      
      const errorEntry = {
        id: errorId,
        error,
        context,
        severity,
        timestamp: new Date(),
        resolved: false,
        retryCount: 0,
        category: errorCategories[severity]
      };

      setErrors(prev => new Map(prev).set(errorId, errorEntry));
      
      // Update global error state based on severity
      if (severity === 'CRITICAL') {
        setGlobalErrorState('critical');
      } else if (severity === 'HIGH' && globalErrorState === 'healthy') {
        setGlobalErrorState('degraded');
      }

      return errorId;
    },

    // Resolve an error
    resolveError: (errorId) => {
      setErrors(prev => {
        const newErrors = new Map(prev);
        const error = newErrors.get(errorId);
        if (error) {
          newErrors.set(errorId, { ...error, resolved: true });
        }
        return newErrors;
      });

      // Update global state if no critical errors remain
      const unresolvedCritical = Array.from(errors.values())
        .some(e => e.severity === 'CRITICAL' && !e.resolved && e.id !== errorId);
      
      if (!unresolvedCritical) {
        const unresolvedHigh = Array.from(errors.values())
          .some(e => e.severity === 'HIGH' && !e.resolved && e.id !== errorId);
        
        setGlobalErrorState(unresolvedHigh ? 'degraded' : 'healthy');
      }
    },

    // Retry error resolution
    retryError: async (errorId, retryFunction) => {
      const error = errors.get(errorId);
      if (!error) return;

      try {
        await retryFunction();
        errorManager.resolveError(errorId);
      } catch (retryError) {
        setErrors(prev => {
          const newErrors = new Map(prev);
          const errorEntry = newErrors.get(errorId);
          if (errorEntry) {
            newErrors.set(errorId, {
              ...errorEntry,
              retryCount: errorEntry.retryCount + 1,
              lastRetryError: retryError
            });
          }
          return newErrors;
        });
      }
    },

    // Get errors by category
    getErrorsByCategory: (category) => {
      return Array.from(errors.values())
        .filter(error => error.severity === category && !error.resolved);
    },

    // Get all active errors
    getActiveErrors: () => {
      return Array.from(errors.values())
        .filter(error => !error.resolved);
    },

    // Clear resolved errors
    clearResolvedErrors: () => {
      setErrors(prev => {
        const newErrors = new Map();
        Array.from(prev.values())
          .filter(error => !error.resolved)
          .forEach(error => newErrors.set(error.id, error));
        return newErrors;
      });
    }
  }), [errors, globalErrorState]);

  // Auto-retry mechanism for retryable errors
  useEffect(() => {
    const retryableErrors = Array.from(errors.values())
      .filter(error => 
        !error.resolved && 
        error.category.autoRetry && 
        error.retryCount < 3
      );

    retryableErrors.forEach(error => {
      const delay = Math.pow(2, error.retryCount) * 1000; // Exponential backoff
      
      setTimeout(() => {
        if (error.context.retryFunction) {
          errorManager.retryError(error.id, error.context.retryFunction);
        }
      }, delay);
    });
  }, [errors, errorManager]);

  const contextValue = useMemo(() => ({
    ...errorManager,
    errors,
    globalErrorState,
    errorCategories
  }), [errorManager, errors, globalErrorState]);

  return (
    <ErrorManagementContext.Provider value={contextValue}>
      {children}
      <GlobalErrorDisplay />
    </ErrorManagementContext.Provider>
  );
}

// Helper function to classify errors
function classifyError(error) {
  // Network errors
  if (error.name === 'NetworkError' || error.message.includes('fetch')) {
    return 'HIGH';
  }
  
  // Authentication errors
  if (error.status === 401 || error.status === 403) {
    return 'CRITICAL';
  }
  
  // Code splitting errors
  if (error.name === 'ChunkLoadError') {
    return 'MEDIUM';
  }
  
  // Validation errors
  if (error.name === 'ValidationError') {
    return 'LOW';
  }
  
  // Unknown errors default to HIGH
  return 'HIGH';
}

// Hook for using error management
function useErrorManagement() {
  const context = useContext(ErrorManagementContext);
  if (!context) {
    throw new Error('useErrorManagement must be used within ErrorManagementProvider');
  }
  return context;
}

// Global error display component
function GlobalErrorDisplay() {
  const { getActiveErrors, resolveError, globalErrorState } = useErrorManagement();
  const [isVisible, setIsVisible] = useState(false);
  
  const activeErrors = getActiveErrors();
  const criticalErrors = activeErrors.filter(e => e.severity === 'CRITICAL');

  useEffect(() => {
    setIsVisible(criticalErrors.length > 0);
  }, [criticalErrors.length]);

  if (!isVisible) return null;

  return (
    <div className={`global-error-banner ${globalErrorState}`}>
      <div className="error-content">
        <span className="error-icon">[!]</span>
        <div className="error-message">
          {criticalErrors.length === 1 ? (
            <span>A critical error has occurred: {criticalErrors[0].error.message}</span>
          ) : (
            <span>{criticalErrors.length} critical errors require attention</span>
          )}
        </div>
        <div className="error-actions">
          <button
            onClick={() => criticalErrors.forEach(e => resolveError(e.id))}
            className="dismiss-button"
          >
            Dismiss
          </button>
          <button
            onClick={() => window.location.reload()}
            className="reload-button"
          >
            Reload Page
          </button>
        </div>
      </div>
    </div>
  );
}

// Practice-specific error handling hooks
function usePracticeSessionErrors() {
  const { reportError, resolveError } = useErrorManagement();

  const handleSessionError = useCallback((error, sessionId) => {
    const errorId = reportError(error, {
      feature: 'practice-session',
      sessionId,
      retryFunction: () => {
        // Retry logic specific to practice sessions
        return new Promise((resolve, reject) => {
          // Attempt to recover session state
          setTimeout(() => {
            if (Math.random() > 0.3) {
              resolve();
            } else {
              reject(new Error('Retry failed'));
            }
          }, 1000);
        });
      }
    });

    return errorId;
  }, [reportError]);

  return { handleSessionError, resolveError };
}

// Usage in practice components
function PracticeSessionPlayer({ sessionId }) {
  const { handleSessionError } = usePracticeSessionErrors();
  const [sessionData, setSessionData] = useState(null);
  const [error, setError] = useState(null);

  const loadSession = useCallback(async () => {
    try {
      const data = await api.getSession(sessionId);
      setSessionData(data);
      setError(null);
    } catch (loadError) {
      setError(loadError);
      handleSessionError(loadError, sessionId);
    }
  }, [sessionId, handleSessionError]);

  useEffect(() => {
    loadSession();
  }, [loadSession]);

  if (error) {
    return (
      <div className="session-error">
        <p>Failed to load practice session</p>
        <button onClick={loadSession}>Retry</button>
      </div>
    );
  }

  // Component implementation...
}
```

:::

### Async error handling patterns {.unnumbered .unlisted}

Modern React applications heavily rely on asynchronous operations, requiring sophisticated patterns for handling async errors, implementing retry logic, and managing loading states with proper error boundaries.

::: example

```jsx
// Advanced async error handling hook
function useAsyncOperation(operation, options = {}) {
  const {
    retries = 3,
    retryDelay = 1000,
    timeout = 30000,
    onError,
    onSuccess,
    dependencies = []
  } = options;

  const [state, setState] = useState({
    data: null,
    loading: false,
    error: null,
    retryCount: 0
  });

  const { reportError } = useErrorManagement();

  const executeOperation = useCallback(async (...args) => {
    let currentRetry = 0;
    
    setState(prev => ({ 
      ...prev, 
      loading: true, 
      error: null,
      retryCount: 0 
    }));

    while (currentRetry <= retries) {
      try {
        // Create timeout promise
        const timeoutPromise = new Promise((_, reject) =>
          setTimeout(() => reject(new Error('Operation timeout')), timeout)
        );

        // Race operation against timeout
        const data = await Promise.race([
          operation(...args),
          timeoutPromise
        ]);

        setState(prev => ({
          ...prev,
          data,
          loading: false,
          error: null,
          retryCount: currentRetry
        }));

        if (onSuccess) {
          onSuccess(data);
        }

        return data;

      } catch (error) {
        currentRetry++;
        
        setState(prev => ({
          ...prev,
          retryCount: currentRetry,
          error: currentRetry > retries ? error : prev.error
        }));

        if (currentRetry <= retries) {
          // Exponential backoff for retries
          const delay = retryDelay * Math.pow(2, currentRetry - 1);
          await new Promise(resolve => setTimeout(resolve, delay));
        } else {
          // Final failure - report error and update state
          setState(prev => ({
            ...prev,
            loading: false,
            error
          }));

          const errorId = reportError(error, {
            operation: operation.name || 'async-operation',
            args,
            retries,
            finalRetryCount: currentRetry - 1
          });

          if (onError) {
            onError(error, errorId);
          }

          throw error;
        }
      }
    }
  }, [operation, retries, retryDelay, timeout, onError, onSuccess, reportError, ...dependencies]);

  const reset = useCallback(() => {
    setState({
      data: null,
      loading: false,
      error: null,
      retryCount: 0
    });
  }, []);

  return {
    ...state,
    execute: executeOperation,
    reset
  };
}

// Async error boundary for handling promise rejections
function AsyncErrorBoundary({ children, fallback }) {
  const [asyncError, setAsyncError] = useState(null);
  const { reportError } = useErrorManagement();

  useEffect(() => {
    const handleUnhandledRejection = (event) => {
      setAsyncError(event.reason);
      reportError(event.reason, {
        type: 'unhandled-promise-rejection',
        source: 'async-error-boundary'
      });
      event.preventDefault();
    };

    window.addEventListener('unhandledrejection', handleUnhandledRejection);
    
    return () => {
      window.removeEventListener('unhandledrejection', handleUnhandledRejection);
    };
  }, [reportError]);

  const resetAsyncError = useCallback(() => {
    setAsyncError(null);
  }, []);

  if (asyncError) {
    if (fallback) {
      return fallback({ error: asyncError, reset: resetAsyncError });
    }

    return (
      <div className="async-error-fallback">
        <h3>Async Operation Failed</h3>
        <p>An asynchronous operation encountered an error.</p>
        <button onClick={resetAsyncError}>Continue</button>
        <details>
          <summary>Error Details</summary>
          <pre>{asyncError.message}</pre>
        </details>
      </div>
    );
  }

  return children;
}

// Practice session async operations
function usePracticeSessionOperations(sessionId) {
  const api = useService('apiClient');
  const { reportError } = useErrorManagement();

  // Load session data with error handling
  const loadSession = useAsyncOperation(
    async (id) => {
      const session = await api.getSession(id);
      return session;
    },
    {
      retries: 2,
      timeout: 10000,
      onError: (error, errorId) => {
        console.error('Failed to load session:', error);
      }
    }
  );

  // Save session progress with retry logic
  const saveProgress = useAsyncOperation(
    async (progressData) => {
      const result = await api.saveSessionProgress(sessionId, progressData);
      return result;
    },
    {
      retries: 5, // More retries for save operations
      retryDelay: 500,
      onError: (error, errorId) => {
        // Show user notification for save failures
        showNotification('Failed to save progress', 'error');
      },
      onSuccess: (data) => {
        showNotification('Progress saved', 'success');
      }
    }
  );

  // Upload audio recording with progress tracking
  const uploadRecording = useAsyncOperation(
    async (audioBlob, onProgress) => {
      const formData = new FormData();
      formData.append('audio', audioBlob);
      formData.append('sessionId', sessionId);

      const result = await api.uploadRecording(formData, {
        onUploadProgress: onProgress
      });

      return result;
    },
    {
      retries: 3,
      timeout: 60000, // Longer timeout for uploads
      onError: (error, errorId) => {
        if (error.name === 'NetworkError') {
          showNotification('Check your internet connection and try again', 'warning');
        } else {
          showNotification('Failed to upload recording', 'error');
        }
      }
    }
  );

  return {
    loadSession,
    saveProgress,
    uploadRecording
  };
}

// Component using async error patterns
function PracticeSessionDashboard({ sessionId }) {
  const { loadSession, saveProgress } = usePracticeSessionOperations(sessionId);
  const [autoSaveEnabled, setAutoSaveEnabled] = useState(true);

  // Load session on mount
  useEffect(() => {
    loadSession.execute(sessionId);
  }, [sessionId, loadSession.execute]);

  // Auto-save with error handling
  useEffect(() => {
    if (!autoSaveEnabled || !loadSession.data) return;

    const autoSaveInterval = setInterval(async () => {
      try {
        await saveProgress.execute({
          sessionId,
          timestamp: Date.now(),
          progressData: getCurrentProgressData()
        });
      } catch (error) {
        // Auto-save errors are handled by the async operation
        // We might want to disable auto-save after multiple failures
        if (saveProgress.retryCount >= 3) {
          setAutoSaveEnabled(false);
          showNotification('Auto-save disabled due to errors', 'warning');
        }
      }
    }, 30000); // Auto-save every 30 seconds

    return () => clearInterval(autoSaveInterval);
  }, [autoSaveEnabled, loadSession.data, saveProgress, sessionId]);

  if (loadSession.loading) {
    return <div>Loading session...</div>;
  }

  if (loadSession.error) {
    return (
      <div className="session-load-error">
        <h3>Failed to load session</h3>
        <p>Retry attempt {loadSession.retryCount}</p>
        <button onClick={() => loadSession.execute(sessionId)}>
          Try Again
        </button>
      </div>
    );
  }

  return (
    <AsyncErrorBoundary
      fallback={({ error, reset }) => (
        <div className="session-async-error">
          <h3>Session Error</h3>
          <p>An error occurred during session operation.</p>
          <button onClick={reset}>Continue</button>
        </div>
      )}
    >
      <div className="practice-session-dashboard">
        {/* Session content */}
        <div className="auto-save-status">
          {saveProgress.loading && <span>Saving...</span>}
          {saveProgress.error && (
            <span className="save-error">
              Save failed (retry {saveProgress.retryCount})
            </span>
          )}
          {!autoSaveEnabled && (
            <button onClick={() => setAutoSaveEnabled(true)}>
              Enable Auto-save
            </button>
          )}
        </div>
      </div>
    </AsyncErrorBoundary>
  );
}
```

:::

Advanced error handling patterns create resilient applications that gracefully handle failures while maintaining user experience. By combining error boundaries with context-based error management and sophisticated async error handling, you can build applications that not only survive errors but actively learn from them to improve reliability over time.

## Advanced composition techniques

Alright, let's dive into some really sophisticated composition patterns. If you've been thinking that React components are just fancy functions that return JSX, you're about to have your mind blown. These techniques turn component composition into a fine art-we're talking about patterns that let you build incredibly flexible systems while keeping your code clean and maintainable.

I'll be straight with you: these patterns might feel like overkill when you first see them. When I first encountered slot-based composition and polymorphic components, my reaction was "this is way too complex for what I'm building." But then I found myself working on a design system that needed to support dozens of different use cases, and suddenly these patterns went from "overly complex" to "absolute lifesavers."

The secret is that advanced composition isn't about showing off-it's about building component APIs that grow with your needs instead of fighting against them. When done right, these patterns make complex customization feel simple and intuitive.

Modern React applications benefit from composition patterns that separate concerns cleanly, enable complex customization, and maintain performance while providing excellent developer experience. These patterns often eliminate the need for complex prop drilling, reduce coupling between components, and create more testable codebases.

::: important
**Composition over configuration**

Advanced composition patterns favor flexible component assembly over rigid configuration. By creating composable building blocks, you can build complex interfaces from simple, well-tested components while maintaining the ability to customize behavior at any level of the component hierarchy.
:::

### Slot-based composition patterns {.unnumbered .unlisted}

Slot-based composition provides a powerful alternative to traditional prop-based customization, enabling components to accept complex, nested content while maintaining clean interfaces and predictable behavior.

::: example

```jsx
// Advanced slot system for flexible component composition
function createSlotSystem() {
  // Slot provider for distributing named content
  const SlotProvider = ({ slots, children }) => {
    const slotMap = useMemo(() => {
      const map = new Map();
      
      // Process slot definitions
      Object.entries(slots || {}).forEach(([name, content]) => {
        map.set(name, content);
      });

      // Extract slots from children
      React.Children.forEach(children, (child) => {
        if (React.isValidElement(child) && child.props.slot) {
          map.set(child.props.slot, child);
        }
      });

      return map;
    }, [slots, children]);

    return (
      <SlotContext.Provider value={slotMap}>
        {children}
      </SlotContext.Provider>
    );
  };

  // Slot consumer for rendering named content
  const Slot = ({ name, fallback, multiple = false, ...props }) => {
    const slots = useContext(SlotContext);
    const content = slots.get(name);

    if (!content && fallback) {
      return typeof fallback === 'function' ? fallback(props) : fallback;
    }

    if (!content) return null;

    // Handle multiple content items
    if (multiple && Array.isArray(content)) {
      return content.map((item, index) => (
        <Fragment key={index}>
          {React.isValidElement(item) ? React.cloneElement(item, props) : item}
        </Fragment>
      ));
    }

    // Single content item
    return React.isValidElement(content) 
      ? React.cloneElement(content, props) 
      : content;
  };

  return { SlotProvider, Slot };
}

const { SlotProvider, Slot } = createSlotSystem();
const SlotContext = createContext(new Map());

// Practice session card with slot-based composition
function PracticeSessionCard({ session, children, ...slots }) {
  return (
    <SlotProvider slots={slots}>
      <div className="practice-session-card">
        <header className="card-header">
          <div className="session-info">
            <h3 className="session-title">{session.title}</h3>
            <Slot 
              name="subtitle" 
              fallback={<p className="session-date">{session.date}</p>}
            />
          </div>
          
          <Slot 
            name="headerActions"
            fallback={<DefaultHeaderActions sessionId={session.id} />}
            session={session}
          />
        </header>

        <div className="card-body">
          <Slot 
            name="content"
            fallback={<DefaultSessionContent session={session} />}
            session={session}
          />
          
          <div className="session-metrics">
            <Slot 
              name="metrics"
              multiple
              session={session}
            />
          </div>
        </div>

        <footer className="card-footer">
          <Slot 
            name="footerActions"
            fallback={<DefaultFooterActions session={session} />}
            session={session}
          />
          
          <Slot name="extraContent" />
        </footer>

        {children}
      </div>
    </SlotProvider>
  );
}

// Usage with different slot configurations
function PracticeSessionList() {
  return (
    <div className="session-list">
      {sessions.map(session => (
        <PracticeSessionCard
          key={session.id}
          session={session}
          headerActions={<CustomSessionActions session={session} />}
          metrics={[
            <MetricBadge key="duration" value={session.duration} label="Duration" />,
            <MetricBadge key="score" value={session.score} label="Score" />,
            <MetricBadge key="accuracy" value={session.accuracy} label="Accuracy" />
          ]}
        >
          <SessionProgress sessionId={session.id} slot="content" />
          <ShareButton sessionId={session.id} slot="footerActions" />
        </PracticeSessionCard>
      ))}
    </div>
  );
}

// Slot-based modal system
function Modal({ isOpen, onClose, children, ...slots }) {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <SlotProvider slots={slots}>
          <div className="modal-header">
            <Slot name="title" fallback={<h2>Modal</h2>} />
            <Slot 
              name="closeButton"
              fallback={<button onClick={onClose}>×</button>}
              onClose={onClose}
            />
          </div>
          
          <div className="modal-body">
            <Slot name="content" fallback={children} />
          </div>
          
          <div className="modal-footer">
            <Slot 
              name="actions"
              fallback={<button onClick={onClose}>Close</button>}
              onClose={onClose}
            />
          </div>
        </SlotProvider>
      </div>
    </div>
  );
}

// Usage with complex customization
function SessionEditModal({ session, isOpen, onClose, onSave }) {
  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={<h2>Edit Practice Session</h2>}
      content={<SessionEditForm session={session} onSave={onSave} />}
      actions={
        <div className="modal-actions">
          <button onClick={onClose}>Cancel</button>
          <button onClick={onSave} className="primary">Save Changes</button>
        </div>
      }
    />
  );
}
```

:::

### Builder pattern for complex components {.unnumbered .unlisted}

The builder pattern enables the construction of complex components through a fluent, chainable API that provides excellent developer experience and type safety.

::: example

```jsx
// Advanced component builder system
class ComponentBuilder {
  constructor(Component) {
    this.Component = Component;
    this.props = {};
    this.children = [];
    this.slots = {};
    this.middlewares = [];
  }

  // Add props with validation
  withProps(props) {
    this.props = { ...this.props, ...props };
    return this;
  }

  // Add children
  withChildren(...children) {
    this.children.push(...children);
    return this;
  }

  // Add named slots
  withSlot(name, content) {
    this.slots[name] = content;
    return this;
  }

  // Add middleware for prop transformation
  withMiddleware(middleware) {
    this.middlewares.push(middleware);
    return this;
  }

  // Conditional prop setting
  when(condition, callback) {
    if (condition) {
      callback(this);
    }
    return this;
  }

  // Build the final component
  build() {
    // Apply middlewares to transform props
    const finalProps = this.middlewares.reduce(
      (props, middleware) => middleware(props),
      { ...this.props, ...this.slots }
    );

    return React.createElement(
      this.Component,
      finalProps,
      ...this.children
    );
  }

  // Create a reusable preset
  preset(name, configuration) {
    const builder = new ComponentBuilder(this.Component);
    configuration(builder);
    
    // Store preset for reuse
    ComponentBuilder.presets = ComponentBuilder.presets || {};
    ComponentBuilder.presets[name] = configuration;
    
    return builder;
  }

  // Apply a preset
  applyPreset(name) {
    const preset = ComponentBuilder.presets?.[name];
    if (preset) {
      preset(this);
    }
    return this;
  }
}

// Practice session builder
function createPracticeSessionBuilder() {
  return new ComponentBuilder(PracticeSessionCard);
}

// Middleware for automatic prop enhancement
const withAnalytics = (props) => ({
  ...props,
  onClick: (originalOnClick) => (...args) => {
    // Track click events
    analytics.track('session_card_clicked', { sessionId: props.session?.id });
    if (originalOnClick) originalOnClick(...args);
  }
});

const withAccessibility = (props) => ({
  ...props,
  role: props.role || 'article',
  tabIndex: props.tabIndex || 0,
  'aria-label': props['aria-label'] || `Practice session: ${props.session?.title}`
});

// Usage with builder pattern
function SessionGallery({ sessions, viewMode, userRole }) {
  return (
    <div className="session-gallery">
      {sessions.map(session => {
        const builder = createPracticeSessionBuilder()
          .withProps({ session })
          .withMiddleware(withAnalytics)
          .withMiddleware(withAccessibility)
          .when(viewMode === 'detailed', builder => 
            builder
              .withSlot('metrics', <DetailedMetrics session={session} />)
              .withSlot('content', <SessionAnalysis session={session} />)
          )
          .when(viewMode === 'compact', builder =>
            builder
              .withSlot('content', <CompactSessionInfo session={session} />)
          )
          .when(userRole === 'admin', builder =>
            builder
              .withSlot('headerActions', <AdminActions session={session} />)
          );

        return builder.build();
      })}
    </div>
  );
}

// Form builder for complex forms
class FormBuilder extends ComponentBuilder {
  constructor() {
    super('form');
    this.fields = [];
    this.validation = {};
    this.sections = new Map();
  }

  addField(name, type, options = {}) {
    this.fields.push({ name, type, options });
    return this;
  }

  addSection(name, fields) {
    this.sections.set(name, fields);
    return this;
  }

  withValidation(fieldName, validator) {
    this.validation[fieldName] = validator;
    return this;
  }

  withConditionalField(fieldName, condition, field) {
    const existingField = this.fields.find(f => f.name === fieldName);
    if (existingField) {
      existingField.conditional = { condition, field };
    }
    return this;
  }

  build() {
    return (
      <DynamicForm
        fields={this.fields}
        sections={this.sections}
        validation={this.validation}
        {...this.props}
      />
    );
  }
}

// Practice session form with builder
function createSessionForm(sessionType) {
  return new FormBuilder()
    .withProps({ className: 'practice-session-form' })
    .addField('title', 'text', { required: true, label: 'Session Title' })
    .addField('duration', 'number', { required: true, min: 1, max: 240 })
    .when(sessionType === 'performance', builder =>
      builder
        .addField('piece', 'select', { 
          options: availablePieces, 
          label: 'Musical Piece' 
        })
        .addField('tempo', 'slider', { min: 60, max: 200, default: 120 })
    )
    .when(sessionType === 'technique', builder =>
      builder
        .addField('technique', 'select', { 
          options: techniques, 
          label: 'Technique Focus' 
        })
        .addField('difficulty', 'radio', { 
          options: ['Beginner', 'Intermediate', 'Advanced'] 
        })
    )
    .addField('notes', 'textarea', { optional: true })
    .withValidation('title', (value) => 
      value.length >= 3 ? null : 'Title must be at least 3 characters'
    );
}

// Layout builder for complex layouts
class LayoutBuilder {
  constructor() {
    this.structure = { type: 'container', children: [] };
    this.current = this.structure;
    this.stack = [];
  }

  row(callback) {
    const row = { type: 'row', children: [] };
    this.current.children.push(row);
    this.stack.push(this.current);
    this.current = row;
    
    if (callback) callback(this);
    
    this.current = this.stack.pop();
    return this;
  }

  col(size, callback) {
    const col = { type: 'col', size, children: [] };
    this.current.children.push(col);
    this.stack.push(this.current);
    this.current = col;
    
    if (callback) callback(this);
    
    this.current = this.stack.pop();
    return this;
  }

  component(Component, props = {}) {
    this.current.children.push({
      type: 'component',
      Component,
      props
    });
    return this;
  }

  build() {
    return <LayoutRenderer structure={this.structure} />;
  }
}

// Layout renderer component
function LayoutRenderer({ structure }) {
  const renderNode = (node, index) => {
    switch (node.type) {
      case 'container':
        return (
          <div key={index} className="layout-container">
            {node.children.map(renderNode)}
          </div>
        );
      
      case 'row':
        return (
          <div key={index} className="layout-row">
            {node.children.map(renderNode)}
          </div>
        );
      
      case 'col':
        return (
          <div key={index} className={`layout-col col-${node.size}`}>
            {node.children.map(renderNode)}
          </div>
        );
      
      case 'component':
        return <node.Component key={index} {...node.props} />;
      
      default:
        return null;
    }
  };

  return renderNode(structure, 0);
}

// Usage: Complex dashboard layout
function PracticeDashboard({ user, sessions, analytics }) {
  const layout = new LayoutBuilder()
    .row(row => row
      .col(8, col => col
        .component(WelcomeHeader, { user })
        .row(innerRow => innerRow
          .col(6, col => col
            .component(ActiveSessionCard, { session: sessions.active })
          )
          .col(6, col => col
            .component(QuickStats, { stats: analytics.today })
          )
        )
        .component(RecentSessions, { sessions: sessions.recent })
      )
      .col(4, col => col
        .component(PracticeCalendar, { sessions: sessions.all })
        .component(GoalsWidget, { goals: user.goals })
        .component(AchievementsWidget, { achievements: user.achievements })
      )
    );

  return layout.build();
}
```

:::

### Polymorphic component patterns {.unnumbered .unlisted}

Polymorphic components provide ultimate flexibility by allowing the underlying element or component type to be changed while maintaining consistent behavior and styling.

::: example

```jsx
// Advanced polymorphic component implementation
function createPolymorphicComponent(defaultComponent = 'div') {
  const PolymorphicComponent = React.forwardRef(
    ({ as: Component = defaultComponent, children, ...props }, ref) => {
      return (
        <Component ref={ref} {...props}>
          {children}
        </Component>
      );
    }
  );

  // Add display name for debugging
  PolymorphicComponent.displayName = 'PolymorphicComponent';

  return PolymorphicComponent;
}

// Base polymorphic text component
const Text = React.forwardRef(({ 
  as = 'span', 
  variant = 'body',
  size = 'medium',
  weight = 'normal',
  color = 'inherit',
  children,
  className,
  ...props 
}, ref) => {
  const Component = as;
  
  const textClasses = classNames(
    'text',
    `text--${variant}`,
    `text--${size}`,
    `text--${weight}`,
    `text--${color}`,
    className
  );

  return (
    <Component ref={ref} className={textClasses} {...props}>
      {children}
    </Component>
  );
});

// Polymorphic button component with advanced features
const Button = React.forwardRef(({
  as = 'button',
  variant = 'primary',
  size = 'medium',
  loading = false,
  disabled = false,
  leftIcon,
  rightIcon,
  children,
  onClick,
  className,
  ...props
}, ref) => {
  const Component = as;
  const isDisabled = disabled || loading;

  const buttonClasses = classNames(
    'button',
    `button--${variant}`,
    `button--${size}`,
    {
      'button--loading': loading,
      'button--disabled': isDisabled
    },
    className
  );

  const handleClick = useCallback((event) => {
    if (isDisabled) {
      event.preventDefault();
      return;
    }
    
    if (onClick) {
      onClick(event);
    }
  }, [onClick, isDisabled]);

  return (
    <Component
      ref={ref}
      className={buttonClasses}
      onClick={handleClick}
      disabled={Component === 'button' ? isDisabled : undefined}
      aria-disabled={isDisabled}
      {...props}
    >
      {leftIcon && (
        <span className="button__icon button__icon--left">
          {leftIcon}
        </span>
      )}
      
      <span className="button__content">
        {loading ? <Spinner size="small" /> : children}
      </span>
      
      {rightIcon && (
        <span className="button__icon button__icon--right">
          {rightIcon}
        </span>
      )}
    </Component>
  );
});

// Polymorphic card component
const Card = React.forwardRef(({
  as = 'div',
  variant = 'default',
  padding = 'medium',
  shadow = true,
  bordered = false,
  clickable = false,
  children,
  className,
  onClick,
  ...props
}, ref) => {
  const Component = as;

  const cardClasses = classNames(
    'card',
    `card--${variant}`,
    `card--padding-${padding}`,
    {
      'card--shadow': shadow,
      'card--bordered': bordered,
      'card--clickable': clickable
    },
    className
  );

  return (
    <Component
      ref={ref}
      className={cardClasses}
      onClick={onClick}
      role={clickable ? 'button' : undefined}
      tabIndex={clickable ? 0 : undefined}
      {...props}
    >
      {children}
    </Component>
  );
});

// Practice session components using polymorphic patterns
function SessionActionButton({ session, action, ...props }) {
  // Dynamically choose component based on action type
  const getButtonProps = () => {
    switch (action.type) {
      case 'external':
        return {
          as: 'a',
          href: action.url,
          target: '_blank',
          rel: 'noopener noreferrer'
        };
      
      case 'route':
        return {
          as: Link,
          to: action.path
        };
      
      case 'download':
        return {
          as: 'a',
          href: action.downloadUrl,
          download: action.filename
        };
      
      default:
        return {
          as: 'button',
          onClick: action.handler
        };
    }
  };

  return (
    <Button
      {...getButtonProps()}
      variant={action.variant || 'secondary'}
      leftIcon={action.icon}
      {...props}
    >
      {action.label}
    </Button>
  );
}

// Polymorphic metric display
function MetricDisplay({ 
  metric, 
  as = 'div',
  interactive = false,
  size = 'medium',
  ...props 
}) {
  const baseProps = {
    className: `metric metric--${size}`,
    role: interactive ? 'button' : undefined,
    tabIndex: interactive ? 0 : undefined
  };

  if (interactive) {
    return (
      <Card
        as={as}
        clickable
        padding="small"
        {...baseProps}
        {...props}
      >
        <MetricContent metric={metric} />
      </Card>
    );
  }

  return (
    <Text
      as={as}
      variant="metric"
      {...baseProps}
      {...props}
    >
      <MetricContent metric={metric} />
    </Text>
  );
}

// Adaptive session list item
function SessionListItem({ session, viewMode, actions = [] }) {
  const getItemComponent = () => {
    switch (viewMode) {
      case 'card':
        return {
          as: Card,
          variant: 'elevated',
          clickable: true
        };
      
      case 'row':
        return {
          as: 'tr',
          className: 'session-row'
        };
      
      case 'list':
        return {
          as: 'li',
          className: 'session-list-item'
        };
      
      default:
        return {
          as: 'div',
          className: 'session-item'
        };
    }
  };

  const itemProps = getItemComponent();

  return (
    <Card {...itemProps}>
      <div className="session-header">
        <Text as="h3" variant="heading" size="small">
          {session.title}
        </Text>
        <Text variant="caption" color="muted">
          {session.date}
        </Text>
      </div>

      <div className="session-content">
        <SessionMetrics session={session} viewMode={viewMode} />
      </div>

      {actions.length > 0 && (
        <div className="session-actions">
          {actions.map((action, index) => (
            <SessionActionButton
              key={index}
              session={session}
              action={action}
              size="small"
            />
          ))}
        </div>
      )}
    </Card>
  );
}

// Usage with different contexts
function PracticeSessionsView({ sessions, viewMode }) {
  const containerProps = {
    card: { as: 'div', className: 'sessions-grid' },
    row: { as: 'table', className: 'sessions-table' },
    list: { as: 'ul', className: 'sessions-list' }
  }[viewMode] || { as: 'div' };

  return (
    <div {...containerProps}>
      {sessions.map(session => (
        <SessionListItem
          key={session.id}
          session={session}
          viewMode={viewMode}
          actions={[
            { type: 'route', path: `/sessions/${session.id}`, label: 'View' },
            { type: 'button', handler: () => editSession(session.id), label: 'Edit' }
          ]}
        />
      ))}
    </div>
  );
}
```

:::

Advanced composition techniques provide the foundation for building truly flexible and maintainable component systems. By leveraging slots, builders, and polymorphic patterns, you can create components that adapt to diverse requirements while maintaining consistency and performance. These patterns enable component libraries that feel native to React while providing the flexibility typically associated with more complex frameworks.

## Performance patterns and optimizations

Here's where we talk about making your React apps actually fast. And I mean really fast, not just "feels fast because it has nice animations" fast. We're going to cover patterns that let you render thousands of items without breaking a sweat, handle frequent updates without janky animations, and build apps that stay responsive even when users are doing their best to overwhelm them.

Performance optimization in React can be a rabbit hole. I've seen developers (myself included) spend hours optimizing components that were already plenty fast, while completely missing the real performance bottlenecks. The trick is knowing where to look and having the right tools in your toolkit for when you really need them.

Don't get me wrong-performance matters. Nothing kills user experience faster than a laggy interface. But advanced performance patterns come with complexity costs, so we need to be smart about when and how we use them. Measure first, optimize second, and always remember that premature optimization is the root of a lot of unnecessary complexity.

Performance patterns must balance optimization benefits with code complexity and maintainability. The most effective optimizations are often architectural decisions that prevent performance problems rather than fixing them after they occur. Understanding when and how to apply different optimization techniques is crucial for building scalable React applications.

::: important
**Measure first, optimize wisely**

Performance optimization should always be driven by actual measurements rather than assumptions. Advanced performance patterns are powerful tools, but they add complexity to your codebase. Apply them judiciously where they provide meaningful benefits, and always validate their impact with real performance metrics.
:::

### Virtual scrolling and windowing patterns {.unnumbered .unlisted}

Virtual scrolling patterns enable efficient rendering of large datasets by only rendering visible items and maintaining the illusion of a complete list through careful positioning and event handling.

::: example

```jsx
// Advanced virtual scrolling implementation
function useVirtualScrolling(options = {}) {
  const {
    itemCount,
    itemHeight,
    containerHeight,
    overscan = 5,
    isItemLoaded = () => true,
    loadMoreItems = () => Promise.resolve(),
    onScroll
  } = options;

  const [scrollTop, setScrollTop] = useState(0);
  const [isScrolling, setIsScrolling] = useState(false);
  
  // Scroll handling with debouncing
  const scrollTimeoutRef = useRef();
  
  const handleScroll = useCallback((event) => {
    const newScrollTop = event.currentTarget.scrollTop;
    setScrollTop(newScrollTop);
    setIsScrolling(true);

    if (onScroll) {
      onScroll(event);
    }

    // Clear existing timeout
    if (scrollTimeoutRef.current) {
      clearTimeout(scrollTimeoutRef.current);
    }

    // Set new timeout
    scrollTimeoutRef.current = setTimeout(() => {
      setIsScrolling(false);
    }, 150);
  }, [onScroll]);

  // Calculate visible range
  const visibleRange = useMemo(() => {
    const startIndex = Math.floor(scrollTop / itemHeight);
    const endIndex = Math.min(
      itemCount - 1,
      Math.ceil((scrollTop + containerHeight) / itemHeight)
    );

    // Add overscan items
    const overscanStartIndex = Math.max(0, startIndex - overscan);
    const overscanEndIndex = Math.min(itemCount - 1, endIndex + overscan);

    return {
      startIndex: overscanStartIndex,
      endIndex: overscanEndIndex,
      visibleStartIndex: startIndex,
      visibleEndIndex: endIndex
    };
  }, [scrollTop, itemHeight, containerHeight, itemCount, overscan]);

  // Preload items that aren't loaded yet
  useEffect(() => {
    const { startIndex, endIndex } = visibleRange;
    const unloadedItems = [];

    for (let i = startIndex; i <= endIndex; i++) {
      if (!isItemLoaded(i)) {
        unloadedItems.push(i);
      }
    }

    if (unloadedItems.length > 0) {
      loadMoreItems(unloadedItems[0], unloadedItems[unloadedItems.length - 1]);
    }
  }, [visibleRange, isItemLoaded, loadMoreItems]);

  // Calculate total height and offset
  const totalHeight = itemCount * itemHeight;
  const offsetY = visibleRange.startIndex * itemHeight;

  return {
    scrollTop,
    isScrolling,
    visibleRange,
    totalHeight,
    offsetY,
    handleScroll
  };
}

// Virtual scrolling container component
function VirtualScrollContainer({
  height,
  itemCount,
  itemHeight,
  children,
  className = '',
  onItemsRendered,
  ...props
}) {
  const containerRef = useRef();
  
  const {
    visibleRange,
    totalHeight,
    offsetY,
    handleScroll,
    isScrolling
  } = useVirtualScrolling({
    itemCount,
    itemHeight,
    containerHeight: height,
    ...props
  });

  // Notify parent of rendered items
  useEffect(() => {
    if (onItemsRendered) {
      onItemsRendered(visibleRange);
    }
  }, [visibleRange, onItemsRendered]);

  const items = [];
  for (let i = visibleRange.startIndex; i <= visibleRange.endIndex; i++) {
    items.push(
      <div
        key={i}
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: itemHeight,
          transform: `translateY(${i * itemHeight}px)`
        }}
      >
        {children({ index: i, isScrolling })}
      </div>
    );
  }

  return (
    <div
      ref={containerRef}
      className={`virtual-scroll-container ${className}`}
      style={{ height, overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div
          style={{
            transform: `translateY(${offsetY}px)`,
            position: 'relative'
          }}
        >
          {items}
        </div>
      </div>
    </div>
  );
}

// Practice sessions virtual list
function VirtualPracticeSessionsList({ sessions, onSessionSelect }) {
  const [selectedSessionId, setSelectedSessionId] = useState(null);

  const renderSessionItem = useCallback(({ index, isScrolling }) => {
    const session = sessions[index];
    
    if (!session) {
      return <div className="session-item-placeholder">Loading...</div>;
    }

    return (
      <PracticeSessionItem
        session={session}
        isSelected={selectedSessionId === session.id}
        onSelect={setSelectedSessionId}
        isScrolling={isScrolling}
      />
    );
  }, [sessions, selectedSessionId]);

  return (
    <VirtualScrollContainer
      height={600}
      itemCount={sessions.length}
      itemHeight={120}
      className="sessions-virtual-list"
    >
      {renderSessionItem}
    </VirtualScrollContainer>
  );
}

// Optimized session item with conditional rendering
const PracticeSessionItem = React.memo(({
  session,
  isSelected,
  onSelect,
  isScrolling
}) => {
  const handleClick = useCallback(() => {
    onSelect(session.id);
  }, [session.id, onSelect]);

  return (
    <div
      className={`session-item ${isSelected ? 'selected' : ''}`}
      onClick={handleClick}
    >
      <div className="session-header">
        <h3>{session.title}</h3>
        <span className="session-date">{session.date}</span>
      </div>
      
      {/* Only render detailed content when not scrolling */}
      {!isScrolling && (
        <div className="session-details">
          <SessionMetrics session={session} />
          <SessionProgress sessionId={session.id} />
        </div>
      )}
      
      {isScrolling && (
        <div className="session-placeholder">
          <span>Scroll to see details</span>
        </div>
      )}
    </div>
  );
});
```

:::

### Intelligent memoization strategies {.unnumbered .unlisted}

Advanced memoization goes beyond simple React.memo to implement sophisticated caching strategies that adapt to different data patterns and update frequencies.

::: example

```jsx
// Advanced memoization hook with cache management
function useAdvancedMemo(
  factory,
  deps,
  options = {}
) {
  const {
    maxSize = 100,
    ttl = 300000, // 5 minutes
    strategy = 'lru', // 'lru', 'lfu', 'fifo'
    keyGenerator = JSON.stringify,
    onEvict
  } = options;

  const cacheRef = useRef(new Map());
  const accessOrderRef = useRef(new Map());
  const frequencyRef = useRef(new Map());

  // Generate cache key
  const cacheKey = useMemo(() => keyGenerator(deps), deps);

  // Cache management strategies
  const evictionStrategies = {
    lru: () => {
      const entries = Array.from(accessOrderRef.current.entries())
        .sort(([, a], [, b]) => a - b);
      return entries[0]?.[0];
    },
    
    lfu: () => {
      const entries = Array.from(frequencyRef.current.entries())
        .sort(([, a], [, b]) => a - b);
      return entries[0]?.[0];
    },
    
    fifo: () => {
      return cacheRef.current.keys().next().value;
    }
  };

  // Clean expired entries
  const cleanExpired = useCallback(() => {
    const now = Date.now();
    const expired = [];

    for (const [key, entry] of cacheRef.current.entries()) {
      if (now - entry.timestamp > ttl) {
        expired.push(key);
      }
    }

    expired.forEach(key => {
      const entry = cacheRef.current.get(key);
      cacheRef.current.delete(key);
      accessOrderRef.current.delete(key);
      frequencyRef.current.delete(key);
      
      if (onEvict) {
        onEvict(key, entry.value, 'expired');
      }
    });
  }, [ttl, onEvict]);

  // Evict items when cache is full
  const evictIfNeeded = useCallback(() => {
    while (cacheRef.current.size >= maxSize) {
      const keyToEvict = evictionStrategies[strategy]();
      
      if (keyToEvict) {
        const entry = cacheRef.current.get(keyToEvict);
        cacheRef.current.delete(keyToEvict);
        accessOrderRef.current.delete(keyToEvict);
        frequencyRef.current.delete(keyToEvict);
        
        if (onEvict) {
          onEvict(keyToEvict, entry.value, 'evicted');
        }
      } else {
        break;
      }
    }
  }, [maxSize, strategy, onEvict]);

  return useMemo(() => {
    // Clean expired entries first
    cleanExpired();

    // Check if we have a cached value
    const cached = cacheRef.current.get(cacheKey);
    
    if (cached) {
      // Update access tracking
      accessOrderRef.current.set(cacheKey, Date.now());
      const currentFreq = frequencyRef.current.get(cacheKey) || 0;
      frequencyRef.current.set(cacheKey, currentFreq + 1);
      
      return cached.value;
    }

    // Compute new value
    const value = factory();
    
    // Evict if needed before adding
    evictIfNeeded();
    
    // Cache the new value
    cacheRef.current.set(cacheKey, {
      value,
      timestamp: Date.now()
    });
    accessOrderRef.current.set(cacheKey, Date.now());
    frequencyRef.current.set(cacheKey, 1);

    return value;
  }, [cacheKey, factory, cleanExpired, evictIfNeeded]);
}

// Selector memoization for complex state derivations
function createMemoizedSelector(selector, options = {}) {
  let lastArgs = [];
  let lastResult;
  
  const {
    compareArgs = (a, b) => a.every((arg, i) => Object.is(arg, b[i])),
    maxSize = 10
  } = options;

  const cache = new Map();
  
  return (...args) => {
    // Check if arguments have changed
    if (lastArgs.length === args.length && compareArgs(args, lastArgs)) {
      return lastResult;
    }

    // Generate cache key
    const cacheKey = JSON.stringify(args);
    
    // Check cache
    if (cache.has(cacheKey)) {
      const cached = cache.get(cacheKey);
      lastArgs = args;
      lastResult = cached;
      return cached;
    }

    // Compute new result
    const result = selector(...args);
    
    // Manage cache size
    if (cache.size >= maxSize) {
      const firstKey = cache.keys().next().value;
      cache.delete(firstKey);
    }
    
    // Cache result
    cache.set(cacheKey, result);
    lastArgs = args;
    lastResult = result;
    
    return result;
  };
}

// Practice session analytics with intelligent memoization
function usePracticeAnalytics(sessions, filters = {}) {
  // Memoized calculation of session statistics
  const sessionStats = useAdvancedMemo(
    () => {
      console.log('Computing session statistics...');
      
      return {
        totalDuration: sessions.reduce((sum, s) => sum + s.duration, 0),
        averageScore: sessions.reduce((sum, s) => sum + s.score, 0) / sessions.length,
        practiceStreak: calculatePracticeStreak(sessions),
        weakAreas: identifyWeakAreas(sessions),
        improvements: trackImprovements(sessions)
      };
    },
    [sessions],
    {
      maxSize: 50,
      ttl: 60000, // 1 minute
      keyGenerator: (deps) => `stats_${deps[0].length}_${deps[0].reduce((h, s) => h + s.id, 0)}`
    }
  );

  // Memoized filtered sessions
  const filteredSessions = useAdvancedMemo(
    () => {
      console.log('Filtering sessions...');
      
      return sessions.filter(session => {
        if (filters.dateRange) {
          const sessionDate = new Date(session.date);
          const { start, end } = filters.dateRange;
          if (sessionDate < start || sessionDate > end) return false;
        }
        
        if (filters.minScore && session.score < filters.minScore) return false;
        if (filters.technique && session.technique !== filters.technique) return false;
        
        return true;
      });
    },
    [sessions, filters],
    {
      maxSize: 20,
      strategy: 'lfu'
    }
  );

  // Advanced progress calculations
  const progressData = useAdvancedMemo(
    () => {
      console.log('Computing progress data...');
      
      const sortedSessions = [...filteredSessions].sort((a, b) => 
        new Date(a.date) - new Date(b.date)
      );

      return {
        scoreProgression: calculateScoreProgression(sortedSessions),
        skillDevelopment: analyzeSkillDevelopment(sortedSessions),
        practicePatterns: identifyPracticePatterns(sortedSessions),
        goalProgress: calculateGoalProgress(sortedSessions)
      };
    },
    [filteredSessions],
    {
      maxSize: 30,
      ttl: 120000, // 2 minutes
      onEvict: (key, value, reason) => {
        console.log(`Progress cache evicted: ${key} (${reason})`);
      }
    }
  );

  return {
    sessionStats,
    filteredSessions,
    progressData,
    cacheStats: {
      // Could expose cache performance metrics
    }
  };
}

// Component with intelligent re-rendering
const PracticeAnalyticsDashboard = React.memo(({
  sessions,
  filters,
  dateRange
}) => {
  const { sessionStats, progressData } = usePracticeAnalytics(sessions, filters);

  // Memoized chart data preparation
  const chartData = useMemo(() => {
    return {
      scoreChart: prepareScoreChartData(progressData.scoreProgression),
      skillChart: prepareSkillChartData(progressData.skillDevelopment),
      patternChart: preparePatternChartData(progressData.practicePatterns)
    };
  }, [progressData]);

  return (
    <div className="analytics-dashboard">
      <StatisticsOverview stats={sessionStats} />
      <ProgressCharts data={chartData} />
      <GoalProgressWidget progress={progressData.goalProgress} />
    </div>
  );
}, (prevProps, nextProps) => {
  // Custom comparison for complex props
  return (
    prevProps.sessions.length === nextProps.sessions.length &&
    prevProps.sessions.every((session, i) => 
      session.id === nextProps.sessions[i]?.id &&
      session.lastModified === nextProps.sessions[i]?.lastModified
    ) &&
    JSON.stringify(prevProps.filters) === JSON.stringify(nextProps.filters)
  );
});
```

:::

### Concurrent rendering optimization {.unnumbered .unlisted}

React 18's concurrent features enable sophisticated optimization patterns that can improve perceived performance through intelligent task scheduling and priority management.

::: example

```jsx
// Advanced concurrent rendering patterns
function useConcurrentState(initialState, options = {}) {
  const {
    isPending: customIsPending,
    startTransition: customStartTransition
  } = useTransition();

  const [urgentState, setUrgentState] = useState(initialState);
  const [deferredState, setDeferredState] = useState(initialState);
  
  const isPending = customIsPending;

  // Immediate updates for urgent state
  const setImmediate = useCallback((update) => {
    const newState = typeof update === 'function' ? update(urgentState) : update;
    setUrgentState(newState);
  }, [urgentState]);

  // Deferred updates for non-urgent state
  const setDeferred = useCallback((update) => {
    customStartTransition(() => {
      const newState = typeof update === 'function' ? update(deferredState) : update;
      setDeferredState(newState);
    });
  }, [deferredState, customStartTransition]);

  // Combined setter that chooses strategy based on priority
  const setState = useCallback((update, priority = 'urgent') => {
    if (priority === 'urgent') {
      setImmediate(update);
    } else {
      setDeferred(update);
    }
  }, [setImmediate, setDeferred]);

  return [
    { urgent: urgentState, deferred: deferredState },
    setState,
    { isPending }
  ];
}

// Prioritized task scheduler
function useTaskScheduler() {
  const [tasks, setTasks] = useState([]);
  const [, startTransition] = useTransition();
  const executingRef = useRef(false);

  const priorities = {
    urgent: 1,
    normal: 2,
    low: 3,
    idle: 4
  };

  const addTask = useCallback((task, priority = 'normal') => {
    const taskItem = {
      id: Date.now() + Math.random(),
      task,
      priority: priorities[priority] || priorities.normal,
      createdAt: Date.now()
    };

    setTasks(current => {
      const newTasks = [...current, taskItem];
      // Sort by priority, then by creation time
      return newTasks.sort((a, b) => {
        if (a.priority !== b.priority) {
          return a.priority - b.priority;
        }
        return a.createdAt - b.createdAt;
      });
    });
  }, []);

  const executeTasks = useCallback(() => {
    if (executingRef.current || tasks.length === 0) return;

    executingRef.current = true;

    const urgentTasks = tasks.filter(t => t.priority === priorities.urgent);
    const otherTasks = tasks.filter(t => t.priority !== priorities.urgent);

    // Execute urgent tasks immediately
    urgentTasks.forEach(({ id, task }) => {
      try {
        task();
      } catch (error) {
        console.error('Task execution failed:', error);
      }
    });

    // Execute other tasks in a transition
    if (otherTasks.length > 0) {
      startTransition(() => {
        otherTasks.forEach(({ id, task }) => {
          try {
            task();
          } catch (error) {
            console.error('Task execution failed:', error);
          }
        });
      });
    }

    // Clear executed tasks
    setTasks([]);
    executingRef.current = false;
  }, [tasks, startTransition]);

  useEffect(() => {
    if (tasks.length > 0) {
      executeTasks();
    }
  }, [tasks, executeTasks]);

  return { addTask };
}

// Practice session list with concurrent rendering
function ConcurrentPracticeSessionsList({ sessions, searchTerm, filters }) {
  const { addTask } = useTaskScheduler();
  
  // Immediate state for user interactions
  const [{ urgent: immediateState, deferred: deferredState }, setState, { isPending }] = 
    useConcurrentState({
      selectedSessions: new Set(),
      sortOrder: 'date',
      viewMode: 'list'
    });

  // Search results with deferred updates
  const [searchResults, setSearchResults] = useState(sessions);
  
  // Immediate response to user input
  const handleSelectionChange = useCallback((sessionId, selected) => {
    setState(prev => {
      const newSelected = new Set(prev.urgent.selectedSessions);
      if (selected) {
        newSelected.add(sessionId);
      } else {
        newSelected.delete(sessionId);
      }
      return { ...prev.urgent, selectedSessions: newSelected };
    }, 'urgent');
  }, [setState]);

  // Deferred search processing
  useEffect(() => {
    if (searchTerm) {
      addTask(() => {
        const filtered = sessions.filter(session =>
          session.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          session.notes?.toLowerCase().includes(searchTerm.toLowerCase())
        );
        setSearchResults(filtered);
      }, 'normal');
    } else {
      setSearchResults(sessions);
    }
  }, [searchTerm, sessions, addTask]);

  // Expensive filtering with low priority
  const filteredSessions = useDeferredValue(
    useMemo(() => {
      return searchResults.filter(session => {
        if (filters.technique && session.technique !== filters.technique) return false;
        if (filters.minScore && session.score < filters.minScore) return false;
        if (filters.dateRange) {
          const sessionDate = new Date(session.date);
          if (sessionDate < filters.dateRange.start || sessionDate > filters.dateRange.end) {
            return false;
          }
        }
        return true;
      });
    }, [searchResults, filters])
  );

  // Sorting with deferred updates
  const sortedSessions = useMemo(() => {
    const order = deferredState.sortOrder || immediateState.sortOrder;
    
    return [...filteredSessions].sort((a, b) => {
      switch (order) {
        case 'date':
          return new Date(b.date) - new Date(a.date);
        case 'score':
          return b.score - a.score;
        case 'duration':
          return b.duration - a.duration;
        case 'title':
          return a.title.localeCompare(b.title);
        default:
          return 0;
      }
    });
  }, [filteredSessions, deferredState.sortOrder, immediateState.sortOrder]);

  return (
    <div className="concurrent-sessions-list">
      <div className="list-controls">
        <SearchControls
          searchTerm={searchTerm}
          onSearch={(term) => {
            // Immediate UI feedback
            setState(prev => ({ ...prev.urgent, searchTerm: term }), 'urgent');
          }}
        />
        
        <SortControls
          sortOrder={immediateState.sortOrder}
          onSortChange={(order) => {
            setState(prev => ({ ...prev.urgent, sortOrder: order }), 'urgent');
          }}
        />
        
        {isPending && <div className="loading-indicator">Updating...</div>}
      </div>

      <div className="sessions-content">
        {sortedSessions.map(session => (
          <SessionCard
            key={session.id}
            session={session}
            selected={immediateState.selectedSessions.has(session.id)}
            onSelectionChange={handleSelectionChange}
            viewMode={immediateState.viewMode}
          />
        ))}
      </div>

      <SelectionSummary
        selectedCount={immediateState.selectedSessions.size}
        totalCount={sortedSessions.length}
      />
    </div>
  );
}

// Optimized session card with concurrent features
const SessionCard = React.memo(({
  session,
  selected,
  onSelectionChange,
  viewMode
}) => {
  const [, startTransition] = useTransition();
  const [details, setDetails] = useState(null);

  // Load detailed data on demand
  const loadDetails = useCallback(() => {
    startTransition(() => {
      // Expensive operation runs in background
      const sessionDetails = calculateSessionAnalytics(session);
      setDetails(sessionDetails);
    });
  }, [session]);

  const handleSelection = useCallback(() => {
    onSelectionChange(session.id, !selected);
  }, [session.id, selected, onSelectionChange]);

  return (
    <div 
      className={`session-card ${selected ? 'selected' : ''}`}
      onClick={handleSelection}
      onMouseEnter={loadDetails}
    >
      <div className="session-basic-info">
        <h3>{session.title}</h3>
        <span className="session-date">{session.date}</span>
      </div>

      {details && (
        <div className="session-details">
          <SessionMetrics metrics={details.metrics} />
          <ProgressIndicator progress={details.progress} />
        </div>
      )}
    </div>
  );
});
```

:::

Performance patterns and optimizations create the foundation for React applications that remain responsive and efficient even under demanding conditions. By combining virtual scrolling, intelligent memoization, and concurrent rendering techniques, you can build applications that handle large datasets and complex interactions while maintaining excellent user experience. The key is to measure performance impact and apply optimizations strategically where they provide the most benefit.

## Testing patterns for advanced components

Okay, let's talk about testing these advanced patterns we've been building. And I'll be honest-testing compound components, provider hierarchies, and custom hooks that manage state machines isn't exactly straightforward. You can't just throw some shallow rendering at these patterns and call it a day.

The thing is, advanced patterns often have emergent behavior-their real value comes from how multiple pieces work together, not just individual component logic. That means our testing strategies need to get more sophisticated too. We need to test workflows, interactions, and integration scenarios that actually reflect how users (and other developers) will experience our components.

But here's the good news: once you get the hang of testing these patterns, you'll have more confidence in your code than you've ever had before. We're going to build tests that focus on behavior and contracts rather than implementation details, which means they'll actually survive refactoring and give you real feedback about whether your components work.

Advanced testing patterns focus on behavior verification rather than implementation details, enabling tests that remain stable as implementations evolve. These patterns also emphasize testing user workflows and integration scenarios that reflect real-world usage patterns.

::: important
**Testing behavior, not implementation**

Advanced component testing should focus on user-observable behavior and component contracts rather than internal implementation details. This approach creates more maintainable tests that provide confidence in functionality while allowing for refactoring and optimization.
:::

### Testing compound components and composition patterns {.unnumbered .unlisted}

Compound components present unique testing challenges because their behavior emerges from the interaction between multiple related components rather than individual component logic.

::: example

```jsx
// Testing utilities for compound components
function createCompoundComponentTester(CompoundComponent) {
  // Helper to render with various child configurations
  const renderWithChildren = (children, props = {}) => {
    return render(
      <CompoundComponent {...props}>
        {children}
      </CompoundComponent>
    );
  };

  // Helper to test child component discovery
  const testChildDiscovery = (expectedChildren) => {
    const { container } = renderWithChildren(expectedChildren);
    
    return {
      hasChild: (childComponent) => {
        const childElements = container.querySelectorAll(
          `[data-compound-child="${childComponent.displayName}"]`
        );
        return childElements.length > 0;
      },
      
      getChildCount: (childComponent) => {
        const childElements = container.querySelectorAll(
          `[data-compound-child="${childComponent.displayName}"]`
        );
        return childElements.length;
      },
      
      getChildProps: (childComponent, index = 0) => {
        const childElements = container.querySelectorAll(
          `[data-compound-child="${childComponent.displayName}"]`
        );
        
        if (childElements[index]) {
          return JSON.parse(childElements[index].dataset.props || '{}');
        }
        return null;
      }
    };
  };

  return {
    renderWithChildren,
    testChildDiscovery
  };
}

// Testing SessionPlayer compound component
describe('SessionPlayer Compound Component', () => {
  const { renderWithChildren, testChildDiscovery } = 
    createCompoundComponentTester(SessionPlayer);

  describe('Component Discovery and Context', () => {
    it('discovers and provides context to child components', () => {
      const children = (
        <>
          <SessionPlayer.Header>
            <SessionPlayer.Title />
            <SessionPlayer.Controls />
          </SessionPlayer.Header>
          <SessionPlayer.Content>
            <SessionPlayer.Waveform />
            <SessionPlayer.Progress />
          </SessionPlayer.Content>
        </>
      );

      const tester = testChildDiscovery(children);
      
      expect(tester.hasChild(SessionPlayer.Title)).toBe(true);
      expect(tester.hasChild(SessionPlayer.Controls)).toBe(true);
      expect(tester.hasChild(SessionPlayer.Waveform)).toBe(true);
      expect(tester.hasChild(SessionPlayer.Progress)).toBe(true);
      expect(tester.getChildCount(SessionPlayer.Controls)).toBe(1);
    });

    it('passes session context to all children', async () => {
      const mockSession = {
        id: 'test-session',
        title: 'Bach Invention No. 1',
        duration: 180,
        audioUrl: '/test-audio.mp3'
      };

      renderWithChildren(
        <SessionPlayer.Title />,
        { session: mockSession }
      );

      await waitFor(() => {
        expect(screen.getByText('Bach Invention No. 1')).toBeInTheDocument();
      });
    });
  });

  describe('Component Interactions', () => {
    it('coordinates playback state across components', async () => {
      const mockSession = createMockSession();
      
      renderWithChildren(
        <>
          <SessionPlayer.Controls />
          <SessionPlayer.Progress />
        </>,
        { session: mockSession }
      );

      const playButton = screen.getByRole('button', { name: /play/i });
      const progressBar = screen.getByRole('progressbar');

      // Start playback
      fireEvent.click(playButton);

      await waitFor(() => {
        expect(screen.getByRole('button', { name: /pause/i })).toBeInTheDocument();
        expect(progressBar).toHaveAttribute('aria-valuenow', '0');
      });

      // Simulate progress
      act(() => {
        jest.advanceTimersByTime(1000);
      });

      await waitFor(() => {
        expect(parseInt(progressBar.getAttribute('aria-valuenow'))).toBeGreaterThan(0);
      });
    });

    it('handles component communication through context', async () => {
      const onTimeUpdate = jest.fn();
      
      renderWithChildren(
        <>
          <SessionPlayer.Waveform onTimeUpdate={onTimeUpdate} />
          <SessionPlayer.Controls />
        </>,
        { session: createMockSession() }
      );

      // Click on waveform to seek
      const waveform = screen.getByTestId('waveform');
      fireEvent.click(waveform, { 
        clientX: 100,  // Simulate click at 50% position
        currentTarget: { offsetWidth: 200 }
      });

      await waitFor(() => {
        expect(onTimeUpdate).toHaveBeenCalledWith(
          expect.objectContaining({
            currentTime: expect.any(Number),
            seeking: true
          })
        );
      });
    });
  });

  describe('Error Boundaries and Resilience', () => {
    it('isolates errors to individual child components', () => {
      const ErrorThrowingChild = () => {
        throw new Error('Test error');
      };

      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      renderWithChildren(
        <>
          <SessionPlayer.Title />
          <ErrorThrowingChild />
          <SessionPlayer.Controls />
        </>,
        { session: createMockSession() }
      );

      // Title and Controls should still render
      expect(screen.getByTestId('session-title')).toBeInTheDocument();
      expect(screen.getByTestId('session-controls')).toBeInTheDocument();

      consoleSpy.mockRestore();
    });
  });
});

// Integration testing for compound components
describe('SessionPlayer Integration', () => {
  it('supports complete user workflow', async () => {
    const mockSession = createMockSession();
    const onComplete = jest.fn();

    render(
      <SessionPlayer session={mockSession} onComplete={onComplete}>
        <SessionPlayer.Header>
          <SessionPlayer.Title />
          <SessionPlayer.Controls />
        </SessionPlayer.Header>
        <SessionPlayer.Content>
          <SessionPlayer.Waveform />
          <SessionPlayer.Progress />
        </SessionPlayer.Content>
        <SessionPlayer.Footer>
          <SessionPlayer.Actions />
        </SessionPlayer.Footer>
      </SessionPlayer>
    );

    // User starts playback
    const playButton = screen.getByRole('button', { name: /play/i });
    fireEvent.click(playButton);

    // User seeks to different position
    const waveform = screen.getByTestId('waveform');
    fireEvent.click(waveform, { 
      clientX: 150,
      currentTarget: { offsetWidth: 200 }
    });

    // User adjusts volume
    const volumeSlider = screen.getByRole('slider', { name: /volume/i });
    fireEvent.change(volumeSlider, { target: { value: '50' } });

    // Simulate playback completion
    act(() => {
      jest.advanceTimersByTime(mockSession.duration * 1000);
    });

    await waitFor(() => {
      expect(onComplete).toHaveBeenCalledWith({
        sessionId: mockSession.id,
        completedAt: expect.any(Date),
        finalPosition: mockSession.duration
      });
    });
  });
});
```

:::

### Testing custom hooks with complex dependencies {.unnumbered .unlisted}

Advanced custom hooks often manage complex state, handle asynchronous operations, and coordinate multiple effects, requiring sophisticated testing strategies that can verify behavior across different scenarios.

::: example

```jsx
// Testing utilities for complex custom hooks
function createHookTester() {
  const results = [];
  let currentResult = null;

  const TestComponent = ({ hookFn, ...props }) => {
    currentResult = hookFn(props);
    results.push(currentResult);
    return null;
  };

  const renderHook = (hookFn, options = {}) => {
    const { initialProps = {}, wrapper } = options;
    
    const utils = render(
      <TestComponent hookFn={hookFn} {...initialProps} />,
      { wrapper }
    );

    return {
      result: {
        current: currentResult
      },
      rerender: (newProps = {}) => {
        utils.rerender(
          <TestComponent hookFn={hookFn} {...initialProps} {...newProps} />
        );
      },
      unmount: utils.unmount,
      history: results
    };
  };

  return { renderHook };
}

// Mock providers for hook testing
function createMockProviders(mocks = {}) {
  const MockProvider = ({ children }) => {
    const mockServices = useMemo(() => ({
      api: {
        createSession: jest.fn(),
        updateSession: jest.fn(),
        deleteSession: jest.fn(),
        getSessions: jest.fn(),
        ...mocks.api
      },
      analytics: {
        track: jest.fn(),
        ...mocks.analytics
      },
      notifications: {
        show: jest.fn(),
        ...mocks.notifications
      },
      ...mocks
    }), []);

    return (
      <ServiceContext.Provider value={mockServices}>
        <ErrorBoundary>
          {children}
        </ErrorBoundary>
      </ServiceContext.Provider>
    );
  };

  return MockProvider;
}

// Testing the advanced practice session hook
describe('usePracticeSession Hook', () => {
  let mockApi, mockAnalytics, mockNotifications;
  let MockProvider;

  beforeEach(() => {
    mockApi = {
      createSession: jest.fn(),
      updateSession: jest.fn(),
      saveProgress: jest.fn(),
      uploadRecording: jest.fn()
    };

    mockAnalytics = {
      track: jest.fn()
    };

    mockNotifications = {
      show: jest.fn()
    };

    MockProvider = createMockProviders({
      api: mockApi,
      analytics: mockAnalytics,
      notifications: mockNotifications
    });

    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.clearAllMocks();
  });

  describe('Session Lifecycle', () => {
    it('creates and manages session state', async () => {
      const { renderHook } = createHookTester();
      const mockSession = { id: 'new-session', title: 'Test Session' };
      
      mockApi.createSession.mockResolvedValue(mockSession);

      const { result } = renderHook(
        () => usePracticeSession(),
        { wrapper: MockProvider }
      );

      expect(result.current.session).toBeNull();
      expect(result.current.loading).toBe(false);

      // Create session
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      expect(result.current.loading).toBe(true);

      await waitFor(() => {
        expect(result.current.session).toEqual(mockSession);
        expect(result.current.loading).toBe(false);
      });

      expect(mockApi.createSession).toHaveBeenCalledWith({ title: 'Test Session' });
      expect(mockAnalytics.track).toHaveBeenCalledWith('session_created', {
        sessionId: 'new-session'
      });
    });

    it('handles session creation errors gracefully', async () => {
      const { renderHook } = createHookTester();
      const error = new Error('Creation failed');
      
      mockApi.createSession.mockRejectedValue(error);

      const { result } = renderHook(
        () => usePracticeSession(),
        { wrapper: MockProvider }
      );

      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      await waitFor(() => {
        expect(result.current.error).toEqual(error);
        expect(result.current.loading).toBe(false);
      });

      expect(mockNotifications.show).toHaveBeenCalledWith(
        'Failed to create session',
        'error'
      );
    });
  });

  describe('Auto-save Functionality', () => {
    it('automatically saves progress at intervals', async () => {
      const { renderHook } = createHookTester();
      const mockSession = { id: 'test-session', title: 'Test Session' };
      
      mockApi.createSession.mockResolvedValue(mockSession);
      mockApi.saveProgress.mockResolvedValue({ success: true });

      const { result } = renderHook(
        () => usePracticeSession({ autoSaveInterval: 5000 }),
        { wrapper: MockProvider }
      );

      // Create session first
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      await waitFor(() => {
        expect(result.current.session).toEqual(mockSession);
      });

      // Update progress
      act(() => {
        result.current.updateProgress({ currentTime: 30, notes: 'Good progress' });
      });

      // Advance time to trigger auto-save
      act(() => {
        jest.advanceTimersByTime(5000);
      });

      await waitFor(() => {
        expect(mockApi.saveProgress).toHaveBeenCalledWith('test-session', {
          currentTime: 30,
          notes: 'Good progress',
          timestamp: expect.any(Number)
        });
      });
    });

    it('disables auto-save after repeated failures', async () => {
      const { renderHook } = createHookTester();
      const mockSession = { id: 'test-session', title: 'Test Session' };
      
      mockApi.createSession.mockResolvedValue(mockSession);
      mockApi.saveProgress.mockRejectedValue(new Error('Save failed'));

      const { result } = renderHook(
        () => usePracticeSession({ autoSaveInterval: 1000, maxSaveRetries: 2 }),
        { wrapper: MockProvider }
      );

      // Create session
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      await waitFor(() => {
        expect(result.current.session).toEqual(mockSession);
      });

      // Trigger multiple failed auto-saves
      for (let i = 0; i < 3; i++) {
        act(() => {
          result.current.updateProgress({ currentTime: i * 10 });
          jest.advanceTimersByTime(1000);
        });

        await waitFor(() => {
          expect(mockApi.saveProgress).toHaveBeenCalled();
        });

        mockApi.saveProgress.mockClear();
      }

      // Auto-save should be disabled after max retries
      expect(result.current.autoSaveEnabled).toBe(false);
      expect(mockNotifications.show).toHaveBeenCalledWith(
        'Auto-save disabled due to errors',
        'warning'
      );
    });
  });

  describe('Recording Management', () => {
    it('handles audio recording workflow', async () => {
      const { renderHook } = createHookTester();
      const mockSession = { id: 'test-session', title: 'Test Session' };
      const mockRecording = { id: 'recording-1', url: '/recording.mp3' };
      
      mockApi.createSession.mockResolvedValue(mockSession);
      mockApi.uploadRecording.mockResolvedValue(mockRecording);

      // Mock MediaRecorder
      const mockMediaRecorder = {
        start: jest.fn(),
        stop: jest.fn(),
        state: 'inactive',
        addEventListener: jest.fn()
      };
      
      global.MediaRecorder = jest.fn(() => mockMediaRecorder);

      const { result } = renderHook(
        () => usePracticeSession(),
        { wrapper: MockProvider }
      );

      // Create session
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      await waitFor(() => {
        expect(result.current.session).toEqual(mockSession);
      });

      // Start recording
      act(() => {
        result.current.startRecording();
      });

      expect(result.current.recording.isRecording).toBe(true);
      expect(mockMediaRecorder.start).toHaveBeenCalled();

      // Stop recording
      act(() => {
        result.current.stopRecording();
      });

      expect(mockMediaRecorder.stop).toHaveBeenCalled();

      // Simulate recording data available
      const mockBlob = new Blob(['audio-data'], { type: 'audio/wav' });
      act(() => {
        result.current.uploadRecording(mockBlob);
      });

      await waitFor(() => {
        expect(mockApi.uploadRecording).toHaveBeenCalledWith(
          expect.any(FormData)
        );
        expect(result.current.recording.uploads).toContainEqual(mockRecording);
      });
    });
  });

  describe('Error Recovery', () => {
    it('recovers from temporary network failures', async () => {
      const { renderHook } = createHookTester();
      
      // Fail first call, succeed second
      mockApi.createSession
        .mockRejectedValueOnce(new Error('Network error'))
        .mockResolvedValue({ id: 'session-1', title: 'Recovered Session' });

      const { result } = renderHook(
        () => usePracticeSession({ retryAttempts: 3, retryDelay: 100 }),
        { wrapper: MockProvider }
      );

      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      // Should retry automatically
      await waitFor(() => {
        expect(result.current.session).toEqual({
          id: 'session-1',
          title: 'Recovered Session'
        });
      });

      expect(mockApi.createSession).toHaveBeenCalledTimes(2);
    });
  });
});

// Performance testing for hooks
describe('usePracticeSession Performance', () => {
  it('memoizes expensive calculations', () => {
    const { renderHook } = createHookTester();
    const expensiveCalculation = jest.fn(() => ({ computed: 'value' }));

    const TestHook = ({ sessions }) => {
      return useMemo(() => expensiveCalculation(sessions), [sessions]);
    };

    const { result, rerender } = renderHook(TestHook, {
      initialProps: { sessions: [1, 2, 3] }
    });

    expect(expensiveCalculation).toHaveBeenCalledTimes(1);

    // Re-render with same props
    rerender({ sessions: [1, 2, 3] });
    expect(expensiveCalculation).toHaveBeenCalledTimes(1);

    // Re-render with different props
    rerender({ sessions: [1, 2, 3, 4] });
    expect(expensiveCalculation).toHaveBeenCalledTimes(2);
  });
});
```

:::

### Testing provider patterns and context systems {.unnumbered .unlisted}

Provider-based architectures require testing strategies that can verify proper dependency injection, context value propagation, and service coordination across component hierarchies.

::: example

```jsx
// Provider testing utilities
function createProviderTester(ProviderComponent) {
  const renderWithProvider = (children, providerProps = {}) => {
    return render(
      <ProviderComponent {...providerProps}>
        {children}
      </ProviderComponent>
    );
  };

  const renderWithoutProvider = (children) => {
    return render(children);
  };

  return {
    renderWithProvider,
    renderWithoutProvider
  };
}

// Service injection testing
describe('ServiceContainer Provider', () => {
  let mockServices;
  let TestConsumer;

  beforeEach(() => {
    mockServices = {
      apiClient: {
        getSessions: jest.fn(),
        createSession: jest.fn()
      },
      analytics: {
        track: jest.fn()
      },
      logger: {
        log: jest.fn(),
        error: jest.fn()
      }
    };

    TestConsumer = ({ serviceName, onServiceReceived }) => {
      const service = useService(serviceName);
      
      useEffect(() => {
        onServiceReceived(service);
      }, [service, onServiceReceived]);

      return <div data-testid={`${serviceName}-consumer`} />;
    };
  });

  it('provides services to consuming components', () => {
    const onServiceReceived = jest.fn();
    
    render(
      <ServiceContainerProvider services={mockServices}>
        <TestConsumer 
          serviceName="apiClient" 
          onServiceReceived={onServiceReceived}
        />
      </ServiceContainerProvider>
    );

    expect(onServiceReceived).toHaveBeenCalledWith(mockServices.apiClient);
  });

  it('throws error when used outside provider', () => {
    const consoleError = jest.spyOn(console, 'error').mockImplementation();

    expect(() => {
      render(<TestConsumer serviceName="apiClient" onServiceReceived={jest.fn()} />);
    }).toThrow('useService must be used within ServiceContainerProvider');

    consoleError.mockRestore();
  });

  it('resolves service dependencies correctly', () => {
    const container = new ServiceContainer();
    
    // Register services with dependencies
    container.singleton('logger', () => mockServices.logger);
    container.register('apiClient', (logger) => ({
      ...mockServices.apiClient,
      logger
    }), ['logger']);

    const onServiceReceived = jest.fn();

    render(
      <ServiceContainerContext.Provider value={container}>
        <TestConsumer 
          serviceName="apiClient" 
          onServiceReceived={onServiceReceived}
        />
      </ServiceContainerContext.Provider>
    );

    expect(onServiceReceived).toHaveBeenCalledWith(
      expect.objectContaining({
        getSessions: expect.any(Function),
        createSession: expect.any(Function),
        logger: mockServices.logger
      })
    );
  });

  it('handles circular dependencies gracefully', () => {
    const container = new ServiceContainer();
    
    container.register('serviceA', (serviceB) => ({ name: 'A' }), ['serviceB']);
    container.register('serviceB', (serviceA) => ({ name: 'B' }), ['serviceA']);

    expect(() => {
      render(
        <ServiceContainerContext.Provider value={container}>
          <TestConsumer serviceName="serviceA" onServiceReceived={jest.fn()} />
        </ServiceContainerContext.Provider>
      );
    }).toThrow('Circular dependency detected');
  });
});

// Multi-provider hierarchy testing
describe('Provider Hierarchy', () => {
  it('supports nested provider configurations', async () => {
    const TestComponent = () => {
      const config = useConfig();
      const api = useApi();
      const auth = useAuth();

      return (
        <div>
          <div data-testid="environment">{config.environment}</div>
          <div data-testid="api-url">{api.baseUrl}</div>
          <div data-testid="user-id">{auth.getCurrentUser()?.id || 'none'}</div>
        </div>
      );
    };

    const mockConfig = {
      environment: 'test',
      apiUrl: 'http://test-api.com'
    };

    const mockUser = { id: 'test-user', name: 'Test User' };

    render(
      <ConfigProvider config={mockConfig}>
        <ApiProvider>
          <AuthProvider initialUser={mockUser}>
            <TestComponent />
          </AuthProvider>
        </ApiProvider>
      </ConfigProvider>
    );

    expect(screen.getByTestId('environment')).toHaveTextContent('test');
    expect(screen.getByTestId('api-url')).toHaveTextContent('http://test-api.com');
    expect(screen.getByTestId('user-id')).toHaveTextContent('test-user');
  });

  it('isolates provider scopes correctly', () => {
    const OuterComponent = () => {
      const theme = useTheme();
      return <div data-testid="outer-theme">{theme.name}</div>;
    };

    const InnerComponent = () => {
      const theme = useTheme();
      return <div data-testid="inner-theme">{theme.name}</div>;
    };

    render(
      <ThemeProvider theme={{ name: 'light' }}>
        <OuterComponent />
        <ThemeProvider theme={{ name: 'dark' }}>
          <InnerComponent />
        </ThemeProvider>
      </ThemeProvider>
    );

    expect(screen.getByTestId('outer-theme')).toHaveTextContent('light');
    expect(screen.getByTestId('inner-theme')).toHaveTextContent('dark');
  });
});

// Provider state management testing
describe('Provider State Management', () => {
  it('maintains state consistency across re-renders', () => {
    const StateConsumer = ({ onStateChange }) => {
      const { state, dispatch } = usePracticeSession();
      
      useEffect(() => {
        onStateChange(state);
      }, [state, onStateChange]);

      return (
        <div>
          <button 
            onClick={() => dispatch({ type: 'START_SESSION' })}
            data-testid="start-session"
          >
            Start
          </button>
          <div data-testid="session-status">{state.status}</div>
        </div>
      );
    };

    const onStateChange = jest.fn();

    const { rerender } = render(
      <PracticeSessionProvider>
        <StateConsumer onStateChange={onStateChange} />
      </PracticeSessionProvider>
    );

    // Initial state
    expect(onStateChange).toHaveBeenLastCalledWith(
      expect.objectContaining({ status: 'idle' })
    );

    // Start session
    fireEvent.click(screen.getByTestId('start-session'));

    expect(onStateChange).toHaveBeenLastCalledWith(
      expect.objectContaining({ status: 'active' })
    );

    // Re-render provider
    rerender(
      <PracticeSessionProvider>
        <StateConsumer onStateChange={onStateChange} />
      </PracticeSessionProvider>
    );

    // State should be preserved
    expect(screen.getByTestId('session-status')).toHaveTextContent('active');
  });

  it('handles provider updates efficiently', () => {
    const renderCount = jest.fn();

    const TestConsumer = ({ level }) => {
      const { sessions } = usePracticeSessions();
      renderCount(`level-${level}`);
      
      return (
        <div data-testid={`level-${level}`}>
          {sessions.length} sessions
        </div>
      );
    };

    const { rerender } = render(
      <PracticeSessionProvider>
        <TestConsumer level={1} />
        <TestConsumer level={2} />
      </PracticeSessionProvider>
    );

    // Initial renders
    expect(renderCount).toHaveBeenCalledTimes(2);
    renderCount.mockClear();

    // Provider value change should trigger re-renders
    rerender(
      <PracticeSessionProvider sessions={[{ id: 1, title: 'New Session' }]}>
        <TestConsumer level={1} />
        <TestConsumer level={2} />
      </PracticeSessionProvider>
    );

    expect(renderCount).toHaveBeenCalledTimes(2);
  });
});

// Integration testing across provider boundaries
describe('Cross-Provider Integration', () => {
  it('coordinates between multiple providers', async () => {
    const IntegratedComponent = () => {
      const { createSession } = usePracticeSessions();
      const { track } = useAnalytics();
      const { show } = useNotifications();

      const handleCreateSession = async () => {
        try {
          const session = await createSession({ title: 'Test Session' });
          track('session_created', { sessionId: session.id });
          show('Session created successfully', 'success');
        } catch (error) {
          show('Failed to create session', 'error');
        }
      };

      return (
        <button onClick={handleCreateSession} data-testid="create-session">
          Create Session
        </button>
      );
    };

    const mockApi = {
      createSession: jest.fn().mockResolvedValue({ id: 'new-session', title: 'Test Session' })
    };

    const mockAnalytics = {
      track: jest.fn()
    };

    const mockNotifications = {
      show: jest.fn()
    };

    render(
      <ServiceContainerProvider services={{
        api: mockApi,
        analytics: mockAnalytics,
        notifications: mockNotifications
      }}>
        <PracticeSessionProvider>
          <IntegratedComponent />
        </PracticeSessionProvider>
      </ServiceContainerProvider>
    );

    fireEvent.click(screen.getByTestId('create-session'));

    await waitFor(() => {
      expect(mockApi.createSession).toHaveBeenCalledWith({ title: 'Test Session' });
      expect(mockAnalytics.track).toHaveBeenCalledWith('session_created', { 
        sessionId: 'new-session' 
      });
      expect(mockNotifications.show).toHaveBeenCalledWith(
        'Session created successfully',
        'success'
      );
    });
  });
});
```

:::

Testing patterns for advanced components require a deep understanding of component behavior, user workflows, and system integration. By focusing on behavior verification, using sophisticated testing utilities, and creating comprehensive integration tests, you can build confidence in complex React applications while maintaining test stability as implementations evolve. The key is to test the right things at the right level of abstraction, ensuring that tests provide value while remaining maintainable.

## Practical exercises

Alright, it's time to get your hands dirty. We've covered a lot of theory and seen a bunch of examples, but there's no substitute for actually building these patterns yourself. Think of these exercises as your chance to take these advanced patterns for a test drive in a safe environment.

I'm not going to lie to you-these exercises are challenging. They're designed to push you to really understand the patterns, not just copy-paste some code. Some of them might take you a few hours to complete properly, and that's totally normal. The goal isn't to race through them, but to really internalize how these patterns work and when to use them.

Here's my suggestion: pick the exercises that relate to problems you're actually facing in your own projects. If you're not dealing with complex notification systems right now, maybe skip that one and focus on the state management or provider pattern exercises instead. These patterns are tools, and tools are best learned when you have a real use case for them.

### Exercise 1: Build a compound notification system

Create a compound component system for displaying notifications that supports various types, actions, and customization options.

**Requirements:**
- Implement `NotificationCenter`, `Notification`, `NotificationTitle`, `NotificationMessage`, `NotificationActions`, and `NotificationIcon` components
- Support different notification types (info, success, warning, error)
- Enable custom positioning and animation
- Provide context for managing notification state
- Support both declarative and imperative APIs

**Starting point:**

```jsx
// Basic structure to extend
function NotificationCenter({ position = 'top-right', children }) {
  // Implement compound component logic
}

NotificationCenter.Notification = function Notification({ children, type = 'info' }) {
  // Implement notification component
};

NotificationCenter.Title = function NotificationTitle({ children }) {
  // Implement title component
};

NotificationCenter.Message = function NotificationMessage({ children }) {
  // Implement message component
};

NotificationCenter.Actions = function NotificationActions({ children }) {
  // Implement actions component
};

NotificationCenter.Icon = function NotificationIcon({ type }) {
  // Implement icon component
};

// Usage example:
<NotificationCenter position="top-right">
  <NotificationCenter.Notification type="success">
    <NotificationCenter.Icon />
    <div>
      <NotificationCenter.Title>Success!</NotificationCenter.Title>
      <NotificationCenter.Message>Your session was saved successfully.</NotificationCenter.Message>
    </div>
    <NotificationCenter.Actions>
      <button>Undo</button>
      <button>View</button>
    </NotificationCenter.Actions>
  </NotificationCenter.Notification>
</NotificationCenter>
```

**Extensions:**
1. Add animation support using CSS transitions or a library like Framer Motion
2. Implement auto-dismiss functionality with progress indicators
3. Add keyboard navigation and accessibility features
4. Create a global notification service using the provider pattern

### Exercise 2: Implement a data table with render props and performance optimization

Build a flexible data table component that uses render props for customization and implements virtualization for performance.

**Requirements:**
- Use render props for custom cell rendering
- Implement virtual scrolling for large datasets
- Support sorting, filtering, and pagination
- Provide selection capabilities
- Include loading and error states
- Optimize for performance with memoization

**Starting point:**

```jsx
function DataTable({
  data,
  columns,
  loading = false,
  error = null,
  onSort,
  onFilter,
  onSelect,
  renderCell,
  renderRow,
  renderHeader,
  height = 400,
  itemHeight = 50
}) {
  // Implement data table with virtual scrolling
}

// Usage example:
<DataTable
  data={practiceSeessions}
  columns={[
    { key: 'title', label: 'Title', sortable: true },
    { key: 'date', label: 'Date', sortable: true },
    { key: 'duration', label: 'Duration' },
    { key: 'score', label: 'Score', sortable: true }
  ]}
  height={600}
  renderCell={({ column, row, value }) => {
    if (column.key === 'score') {
      return <ScoreIndicator score={value} />;
    }
    if (column.key === 'duration') {
      return <DurationFormatter duration={value} />;
    }
    return value;
  }}
  renderRow={({ row, children, selected, onSelect }) => (
    <tr 
      className={selected ? 'selected' : ''} 
      onClick={() => onSelect(row.id)}
    >
      {children}
    </tr>
  )}
  onSort={(column, direction) => {
    // Handle sorting
  }}
  onSelect={(selectedRows) => {
    // Handle selection
  }}
/>
```

**Extensions:**
1. Add column resizing and reordering
2. Implement grouping and aggregation features
3. Add export functionality (CSV, JSON)
4. Create custom filter components for different data types
5. Implement infinite scrolling instead of pagination

### Exercise 3: Create a provider-based theme system with advanced features

Develop a comprehensive theme system using provider patterns that supports multiple themes, custom properties, and runtime theme switching.

**Requirements:**
- Implement hierarchical theme providers
- Support theme inheritance and overrides
- Provide custom hooks for consuming theme values
- Enable runtime theme switching with smooth transitions
- Support custom CSS properties integration
- Include dark/light mode detection and system preference sync

**Starting point:**

```jsx
// Theme provider implementation
function ThemeProvider({ theme, children }) {
  // Implement theme context and CSS custom properties
}

// Custom hooks for theme consumption
function useTheme() {
  // Return current theme values
}

function useThemeProperty(property, fallback) {
  // Return specific theme property with fallback
}

function useColorMode() {
  // Return color mode utilities (dark/light/auto)
}

// Theme configuration structure
const lightTheme = {
  colors: {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#FFFFFF',
    surface: '#F2F2F7',
    text: '#000000'
  },
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px'
  },
  typography: {
    fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
    fontSize: {
      sm: '14px',
      md: '16px',
      lg: '18px',
      xl: '24px'
    }
  },
  borderRadius: {
    sm: '4px',
    md: '8px',
    lg: '12px'
  }
};

// Usage example:
<ThemeProvider theme={lightTheme}>
  <ThemeProvider theme={{ colors: { primary: '#FF6B6B' } }}>
    <App />
  </ThemeProvider>
</ThemeProvider>
```

**Extensions:**
1. Add theme validation and TypeScript support
2. Implement theme persistence using localStorage
3. Create a theme builder/editor interface
4. Add motion and animation theme properties
5. Support multiple color modes per theme (not just dark/light)

### Exercise 4: Build an advanced form system with validation and field composition

Create a sophisticated form system that combines render props, compound components, and custom hooks for maximum flexibility.

**Requirements:**
- Implement field-level and form-level validation
- Support asynchronous validation
- Provide field registration and dependency tracking
- Enable conditional field rendering
- Support multiple validation schemas (Yup, Zod, custom)
- Include accessibility features and error handling

**Starting point:**

```jsx
// Form context and hooks
function FormProvider({ onSubmit, validationSchema, children }) {
  // Implement form state management
}

function useForm() {
  // Return form state and methods
}

function useField(name, options = {}) {
  // Return field state and handlers
}

// Field components
function Field({ name, children, validate, ...props }) {
  // Implement field wrapper with validation
}

function FieldError({ name }) {
  // Display field errors
}

function FieldGroup({ children, title, description }) {
  // Group related fields
}

// Usage example:
<FormProvider 
  onSubmit={async (values) => {
    await createPracticeSession(values);
  }}
  validationSchema={practiceSessionSchema}
>
  <FieldGroup title="Session Details">
    <Field name="title" validate={required}>
      {({ field, meta }) => (
        <div>
          <input 
            {...field} 
            placeholder="Session title"
            className={meta.error ? 'error' : ''}
          />
          <FieldError name="title" />
        </div>
      )}
    </Field>
    
    <Field name="duration" validate={[required, minValue(1)]}>
      {({ field, meta }) => (
        <div>
          <input 
            {...field} 
            type="number"
            placeholder="Duration (minutes)"
          />
          <FieldError name="duration" />
        </div>
      )}
    </Field>
  </FieldGroup>
  
  <ConditionalField 
    condition={(values) => values.duration > 60}
    name="breakTime"
  >
    {({ field }) => (
      <input {...field} placeholder="Break time (minutes)" />
    )}
  </ConditionalField>
  
  <button type="submit">Create Session</button>
</FormProvider>
```

**Extensions:**
1. Add field arrays for dynamic lists
2. Implement wizard/multi-step form functionality
3. Create custom field components for specific data types
4. Add form auto-save and recovery features
5. Support file uploads with progress tracking

### Exercise 5: Implement a real-time collaboration system

Build a real-time collaboration system for practice sessions using advanced patterns including providers, custom hooks, and error boundaries.

**Requirements:**
- Enable multiple users to collaborate on practice sessions
- Implement real-time updates using WebSockets or similar
- Handle connection management and reconnection logic
- Provide conflict resolution for simultaneous edits
- Include presence indicators for active users
- Support offline functionality with sync on reconnect

**Starting point:**

```jsx
// Collaboration provider
function CollaborationProvider({ sessionId, userId, children }) {
  // Implement WebSocket connection and state management
}

// Hooks for collaboration features
function useCollaboration() {
  // Return collaboration state and methods
}

function usePresence() {
  // Return active users and presence information
}

function useRealtimeField(fieldName, initialValue) {
  // Return field value with real-time updates
}

// Collaborative components
function CollaborativeEditor({ fieldName, placeholder }) {
  // Implement real-time collaborative editor
}

function PresenceIndicator() {
  // Show active users
}

function ConnectionStatus() {
  // Display connection state
}

// Usage example:
<CollaborationProvider sessionId="session-123" userId="user-456">
  <div className="collaborative-session">
    <header>
      <h1>Collaborative Practice Session</h1>
      <PresenceIndicator />
      <ConnectionStatus />
    </header>
    
    <CollaborativeEditor 
      fieldName="sessionNotes"
      placeholder="Add practice notes..."
    />
    
    <CollaborativeEditor 
      fieldName="goals"
      placeholder="Session goals..."
    />
    
    <RealtimeMetrics sessionId="session-123" />
  </div>
</CollaborationProvider>
```

**Extensions:**
1. Add operational transformation for text editing
2. Implement user permissions and roles
3. Create activity feeds and change history
4. Add voice/video chat integration
5. Support collaborative annotations on audio files

### Exercise 6: Build a plugin architecture system

Create a flexible plugin system that allows extending the practice app with custom functionality using advanced composition patterns.

**Requirements:**
- Define plugin interfaces and lifecycle hooks
- Implement plugin registration and management
- Support plugin dependencies and versioning
- Provide plugin-specific context and state management
- Enable plugin communication and events
- Include plugin development tools and hot reloading

**Starting point:**

```jsx
// Plugin system foundation
class PluginManager {
  constructor() {
    this.plugins = new Map();
    this.hooks = new Map();
    this.eventBus = new EventTarget();
  }

  register(plugin) {
    // Register and initialize plugin
  }

  unregister(pluginId) {
    // Safely remove plugin
  }

  getPlugin(pluginId) {
    // Get plugin instance
  }

  executeHook(hookName, ...args) {
    // Execute all plugins that implement hook
  }
}

// Plugin provider
function PluginProvider({ plugins = [], children }) {
  // Provide plugin context and management
}

// Plugin hooks
function usePlugin(pluginId) {
  // Get specific plugin instance
}

function usePluginHook(hookName) {
  // Execute plugin hook
}

// Example plugin structure
const analyticsPlugin = {
  id: 'analytics',
  name: 'Advanced Analytics',
  version: '1.0.0',
  dependencies: [],
  
  initialize(context) {
    // Plugin initialization
  },
  
  hooks: {
    'session.created': (session) => {
      // Track session creation
    },
    'session.completed': (session) => {
      // Track session completion
    }
  },
  
  components: {
    'dashboard.widget': AnalyticsWidget,
    'session.sidebar': AnalyticsSidebar
  },
  
  routes: [
    { path: '/analytics', component: AnalyticsPage }
  ]
};

// Usage example:
<PluginProvider plugins={[analyticsPlugin, metronomePlugin, recordingPlugin]}>
  <App>
    <Routes>
      <Route path="/session/:id" element={
        <SessionPage>
          <PluginSlot name="session.sidebar" />
          <SessionContent />
          <PluginSlot name="session.tools" />
        </SessionPage>
      } />
    </Routes>
  </App>
</PluginProvider>
```

**Extensions:**
1. Add plugin marketplace and remote loading
2. Implement plugin sandboxing and security
3. Create visual plugin development tools
4. Add plugin analytics and usage tracking
5. Support plugin themes and styling

### Bonus Challenge: Integrate everything

Combine all the patterns learned in this chapter to build a comprehensive practice session workspace that includes:

- Compound components for flexible UI composition
- Provider patterns for state management and dependency injection
- Advanced hooks for complex logic encapsulation
- Error boundaries for resilient error handling
- Performance optimizations for smooth user experience
- Comprehensive testing coverage

This integration exercise will help you understand how these patterns work together in real-world applications and provide experience with the architectural decisions required for complex React applications.

**Success criteria:**
- Clean, composable component architecture
- Efficient state management and data flow
- Robust error handling and recovery
- Smooth performance with large datasets
- Comprehensive test coverage
- Accessible and user-friendly interface

These exercises provide hands-on experience with the advanced patterns covered in this chapter. Take your time with them-rushing through won't do you any favors. Experiment with different approaches, and don't be afraid to break things. Some of the best learning happens when you try something that doesn't work and then figure out why.

The goal isn't just to implement the requirements, but to understand the trade-offs and design decisions that make these patterns effective. When you're building the compound notification system, ask yourself why you chose one approach over another. When you're implementing the state machine, think about what problems it solves compared to simpler state management.

And here's the most important advice I can give you: relate these exercises back to your own projects. As you're working through them, keep asking "where would I use this in my actual work?" These patterns aren't academic curiosities-they're solutions to real problems that you will encounter as you build more complex React applications.

If you get stuck, take a break. Come back to it later. These patterns represent years of collective wisdom from the React community, and they take time to truly internalize. But once you do, you'll wonder how you ever built complex React apps without them.
