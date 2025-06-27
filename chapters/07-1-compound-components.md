# Advanced React patterns

This chapter marks a significant step forward in your React journey. If you've mastered components, state, and hooks, you're ready to explore the advanced patterns that distinguish great React developers. These patterns will help you build applications that scale gracefully, handle complexity elegantly, and impress your peers with their flexibility and maintainability.

::: tip
**Take your time with this chapter**

These are advanced patterns that even experienced developers sometimes struggle with. Read through once to get the big picture, then revisit the exercises. Focus on how each pattern solves real problems you may have encountered in your own projects.
:::

As your React applications grow beyond simple todo lists and basic forms, you'll encounter challenges that basic component composition can't solve. Need to share complex logic between components? There's a pattern for that. Want to create components that are flexible enough for a design system but simple enough for junior developers? We've got you covered. Need to coordinate complex state across many components? Let's talk about provider patterns.

## Compound components: building flexible APIs

Compound components are a powerful pattern for building flexible, intuitive APIs. Instead of creating a component with dozens of props to control every detail, you let users compose the component using child components. This approach is like giving someone LEGO blocks instead of a pre-built house: much more flexible and often more intuitive.

::: important
**The compound component advantage**

Compound components allow you to express intent through JSX structure. Instead of configuring every option with props, you compose the UI by arranging child components, making your code more readable and maintainable.
:::

Consider how a practice session player might work with compound components:

::: example

```jsx
// Traditional prop-heavy approach (harder to customize)
<SessionPlayer
  session={session}
  onPause={handlePause}
/>

// Compound component approach (more flexible and readable)
<SessionPlayer session={session}>
  <SessionPlayer.Progress />
  <SessionPlayer.Controls />
</SessionPlayer>
```

:::

The compound component version is more verbose but provides much greater flexibility. Users can rearrange components, omit pieces they don't need, and the intent is clear from the JSX structure.

### Implementing Compound Components with Context {.unnumbered .unlisted}

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
      [Pause] Pause
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

- **Shared context**: All child components can access the same state through context.
- **Flexible composition**: Users can arrange components in any order they want.
- **Clean APIs**: Each component has a focused responsibility.
- **Type safety**: The custom hook ensures components are used within the correct context.

### When to Use Compound Components {.unnumbered .unlisted}

Compound components are ideal for UI elements with multiple related parts that users may want to customize or rearrange. They are especially effective for:

- Modal dialogs with headers, content, and footers
- Form components with labels, inputs, and validation messages
- Media players with controls, progress bars, and metadata
- Card components with images, titles, descriptions, and actions
- Navigation components with various menu items and sections

::: tip
**Compound components vs. regular composition**

Use compound components when child components need to share state and behavior. If the components are truly independent, regular composition with separate components may be simpler and more appropriate.
:::
