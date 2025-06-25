# Performance optimization

Let's talk about React performance-but not in the way most tutorials do it. I'm not going to start by telling you to wrap everything in `React.memo` and call it a day. That's like putting a band-aid on a broken bone.

Here's the thing about React performance: most performance problems aren't actually React's fault. They're architectural problems that happen to manifest in React apps. The good news? Once you understand what actually causes performance issues and how to measure them properly, optimization becomes much more straightforward and rewarding.

I've seen too many developers jump straight to micro-optimizations without understanding what they're optimizing for. They'll spend hours memoizing components that re-render once per minute, while completely ignoring the fact that they're re-creating massive objects on every render. We're going to take a different approach: measure first, understand the problem, then apply the right solution.

::: tip
**What you'll learn in this chapter**

- How to identify real performance problems versus imaginary ones
- The React DevTools Profiler and other essential measurement tools
- When and how to use React's built-in optimization hooks effectively
- Patterns for preventing expensive re-renders before they happen
- Advanced techniques like virtualization and code splitting
- How to optimize bundle size and loading performance
- Real-world debugging strategies for complex performance issues
:::

## Understanding React performance fundamentals

Before we start optimizing anything, we need to understand what we're optimizing. React performance issues generally fall into a few categories, and the solutions are very different for each type.

### The anatomy of React performance {.unnumbered .unlisted}

When people say "my React app is slow," they could be talking about several different things:

**Initial load time**: How long it takes for your app to become interactive when someone first visits
**Re-render performance**: How smoothly your app responds to user interactions and state changes
**Memory usage**: How much RAM your app consumes and whether it leaks memory over time
**Bundle size**: How much JavaScript needs to be downloaded before your app can run

Each of these requires different measurement techniques and different optimization strategies. The mistake I see most often is trying to solve a bundle size problem with re-render optimizations, or vice versa.

::: important
**Measure before you optimize**

I cannot stress this enough: you need to measure performance before you try to optimize it. Human perception of performance is notoriously unreliable, and premature optimization is still the root of all evil. React's built-in profiling tools are excellent, and I'm going to show you exactly how to use them.
:::

### React's rendering process {.unnumbered .unlisted}

To understand performance, you need to understand what happens when React renders components. Here's the simplified version:

1. **State changes**: Something triggers a state update (user interaction, API response, timer, etc.)
2. **Component re-render**: React calls your component function again with the new state
3. **Virtual DOM creation**: Your component returns new JSX, creating a virtual DOM tree
4. **Reconciliation**: React compares the new virtual DOM with the previous version
5. **DOM updates**: React updates only the parts of the real DOM that changed
6. **Effect execution**: Any useEffect hooks with changed dependencies run

Performance problems can happen at any of these steps:

- **Expensive component functions**: Your component does too much work during render
- **Unnecessary re-renders**: Components re-render when their output wouldn't actually change
- **Inefficient reconciliation**: React struggles to match up elements between renders
- **Heavy DOM updates**: Too many or complex DOM changes at once
- **Expensive effects**: useEffect callbacks that do too much work

Let me show you what these look like in practice and how to fix them.

## Measuring performance: The React DevTools Profiler

The React DevTools Profiler is hands down the best tool for understanding React performance. If you're not using it, you're flying blind. Let me walk you through how to use it effectively.

### Setting up the Profiler {.unnumbered .unlisted}

First, make sure you have the React Developer Tools browser extension installed. In development mode, you'll see a "Profiler" tab in your browser's dev tools. In production, you'll need to enable profiling manually, but I recommend doing most of your performance analysis in development.

::: example

```jsx
// Example component we'll use for profiling
function MusicLibrary() {
  const [songs, setSongs] = useState([]);
  const [filter, setFilter] = useState('');
  const [sortBy, setSortBy] = useState('title');
  const [selectedGenre, setSelectedGenre] = useState('all');

  // Expensive computation that we'll optimize
  const processedSongs = useMemo(() => {
    console.log('Processing songs...'); // We'll see this in profiler
    
    return songs
      .filter(song => {
        if (selectedGenre !== 'all' && song.genre !== selectedGenre) {
          return false;
        }
        if (filter && !song.title.toLowerCase().includes(filter.toLowerCase())) {
          return false;
        }
        return true;
      })
      .sort((a, b) => {
        if (sortBy === 'title') return a.title.localeCompare(b.title);
        if (sortBy === 'artist') return a.artist.localeCompare(b.artist);
        if (sortBy === 'duration') return a.duration - b.duration;
        return 0;
      });
  }, [songs, filter, sortBy, selectedGenre]);

  return (
    <div className="music-library">
      <LibraryControls
        filter={filter}
        onFilterChange={setFilter}
        sortBy={sortBy}
        onSortChange={setSortBy}
        selectedGenre={selectedGenre}
        onGenreChange={setSelectedGenre}
      />
      
      <SongList songs={processedSongs} />
    </div>
  );
}
```

:::

### Reading profiler results {.unnumbered .unlisted}

When you record a profiling session, the Profiler shows you several key pieces of information:

**Render duration**: How long each component took to render
**Commit duration**: How long React took to apply changes to the DOM
**Component tree**: Which components rendered and why
**Render reasons**: What triggered each re-render

Here's how to interpret these:

- **Long render durations** usually mean expensive computation during render
- **Frequent re-renders** might indicate unnecessary state updates or missing memoization
- **Large commit durations** often point to inefficient DOM operations
- **Cascading re-renders** suggest prop drilling or context overuse

::: tip
**Focus on the biggest problems first**

The Profiler will show you lots of data, but focus on the components that take the longest to render or render most frequently. A component that takes 50ms but only renders once isn't your biggest problem-a component that takes 5ms but renders 100 times per interaction is.
:::

## Preventing unnecessary re-renders

Most React performance issues come down to components re-rendering when they don't need to. Let's look at the most effective strategies for preventing this.

### Understanding when components re-render {.unnumbered .unlisted}

A component re-renders when:

1. **Its state changes** (via setState)
2. **Its props change** (parent passed different props)
3. **Its parent re-renders** (and it's not memoized)
4. **Its context value changes** (if it uses useContext)

The third point is where most problems happen. By default, when a parent component re-renders, all of its children re-render too, regardless of whether their props actually changed.

::: example

```jsx
// Problem: PracticeSession re-renders whenever App re-renders,
// even if session data hasn't changed
function App() {
  const [user, setUser] = useState(null);
  const [notification, setNotification] = useState('');
  const [currentSession] = useState(mockSession);

  // Every time notification changes, PracticeSession re-renders unnecessarily
  return (
    <div>
      <Header user={user} notification={notification} />
      <PracticeSession session={currentSession} />
    </div>
  );
}

// Solution: Memoize PracticeSession so it only re-renders when props change
const MemoizedPracticeSession = React.memo(function PracticeSession({ session }) {
  return (
    <div className="practice-session">
      <h2>{session.piece}</h2>
      <p>Composer: {session.composer}</p>
      <Timer duration={session.duration} />
    </div>
  );
});
```

:::

### Using React.memo effectively {.unnumbered .unlisted}

`React.memo` is React's way of saying "only re-render this component if its props actually changed." But there are some gotchas you need to know about.

::: example

```jsx
// This memo won't work as expected!
const SongList = React.memo(function SongList({ songs, onSongSelect }) {
  return (
    <div>
      {songs.map(song => (
        <SongItem
          key={song.id}
          song={song}
          onClick={() => onSongSelect(song)} // New function every render!
        />
      ))}
    </div>
  );
});

// The parent component
function MusicLibrary() {
  const [songs, setSongs] = useState([]);
  const [selectedSong, setSelectedSong] = useState(null);

  // This creates a new function every render, breaking memo
  const handleSongSelect = (song) => {
    setSelectedSong(song);
  };

  return <SongList songs={songs} onSongSelect={handleSongSelect} />;
}

// Solution: useCallback to stabilize the function reference
function MusicLibrary() {
  const [songs, setSongs] = useState([]);
  const [selectedSong, setSelectedSong] = useState(null);

  // Now the function reference stays stable
  const handleSongSelect = useCallback((song) => {
    setSelectedSong(song);
  }, []); // Empty dependency array because setSelectedSong is stable

  return <SongList songs={songs} onSongSelect={handleSongSelect} />;
}
```

:::

### Custom comparison functions {.unnumbered .unlisted}

Sometimes React's default prop comparison (shallow equality) isn't enough. You can provide a custom comparison function to `React.memo`:

::: example

```jsx
// Component that receives complex props
function AdvancedSongList({ songs, filters, config }) {
  // Expensive rendering logic here
  return (
    <div>
      {/* Complex song list rendering */}
    </div>
  );
}

// Custom comparison function
const arePropsEqual = (prevProps, nextProps) => {
  // Only re-render if songs array length changed or filters are different
  if (prevProps.songs.length !== nextProps.songs.length) {
    return false;
  }
  
  if (prevProps.filters.genre !== nextProps.filters.genre) {
    return false;
  }
  
  if (prevProps.filters.searchTerm !== nextProps.filters.searchTerm) {
    return false;
  }
  
  // Don't care about config changes for this component
  return true;
};

const MemoizedAdvancedSongList = React.memo(AdvancedSongList, arePropsEqual);
```

:::

::: caution
**Don't overuse React.memo**

React.memo has a cost-it needs to compare props on every render. Only use it when:
1. Your component is expensive to render
2. It re-renders frequently with the same props
3. You've measured that it actually improves performance

Wrapping a component that renders quickly in memo can actually make things slower.
:::

## Optimizing expensive computations

Sometimes the performance problem isn't unnecessary re-renders-it's that your component is doing expensive work on every render. This is where `useMemo` and `useCallback` come in.

### Using useMemo for expensive calculations {.unnumbered .unlisted}

`useMemo` lets you cache the result of expensive computations and only recalculate when specific dependencies change.

::: example

```jsx
function PracticeAnalytics({ sessions }) {
  // Without useMemo, this runs on every render
  const analytics = useMemo(() => {
    console.log('Calculating analytics...'); // You'll see this in DevTools
    
    // Expensive calculations
    const totalPracticeTime = sessions.reduce((total, session) => {
      return total + session.duration;
    }, 0);
    
    const averageSessionLength = totalPracticeTime / sessions.length;
    
    const practiceStreak = calculateStreak(sessions);
    
    const mostPracticedPieces = sessions
      .reduce((pieces, session) => {
        pieces[session.piece] = (pieces[session.piece] || 0) + 1;
        return pieces;
      }, {})
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);
    
    const weeklyProgress = calculateWeeklyProgress(sessions);
    
    return {
      totalPracticeTime,
      averageSessionLength,
      practiceStreak,
      mostPracticedPieces,
      weeklyProgress
    };
  }, [sessions]); // Only recalculate when sessions array changes

  return (
    <div className="practice-analytics">
      <h2>Your Practice Analytics</h2>
      
      <div className="stat-grid">
        <StatCard 
          title="Total Practice Time" 
          value={formatTime(analytics.totalPracticeTime)} 
        />
        <StatCard 
          title="Average Session" 
          value={formatTime(analytics.averageSessionLength)} 
        />
        <StatCard 
          title="Current Streak" 
          value={`${analytics.practiceStreak} days`} 
        />
      </div>
      
      <MostPracticedPieces pieces={analytics.mostPracticedPieces} />
      <WeeklyChart data={analytics.weeklyProgress} />
    </div>
  );
}
```

:::

### Using useCallback for stable function references {.unnumbered .unlisted}

`useCallback` is like `useMemo` but for functions. It's particularly useful when passing functions to child components that are wrapped in `React.memo`.

::: example

```jsx
function PracticeSessionManager() {
  const [sessions, setSessions] = useState([]);
  const [filters, setFilters] = useState({ genre: 'all', difficulty: 'all' });

  // Without useCallback, these functions are recreated every render
  const updateSession = useCallback((sessionId, updates) => {
    setSessions(prev => prev.map(session =>
      session.id === sessionId ? { ...session, ...updates } : session
    ));
  }, []); // Empty deps because setSessions is stable

  const deleteSession = useCallback((sessionId) => {
    setSessions(prev => prev.filter(session => session.id !== sessionId));
  }, []);

  const duplicateSession = useCallback((sessionId) => {
    setSessions(prev => {
      const original = prev.find(s => s.id === sessionId);
      if (!original) return prev;
      
      const duplicate = {
        ...original,
        id: Date.now(),
        date: new Date().toISOString(),
        title: `${original.title} (Copy)`
      };
      
      return [...prev, duplicate];
    });
  }, []);

  const updateFilters = useCallback((newFilters) => {
    setFilters(prev => ({ ...prev, ...newFilters }));
  }, []);

  return (
    <div className="session-manager">
      <SessionFilters 
        filters={filters} 
        onFiltersChange={updateFilters} 
      />
      
      <SessionGrid
        sessions={sessions}
        onUpdateSession={updateSession}
        onDeleteSession={deleteSession}
        onDuplicateSession={duplicateSession}
      />
    </div>
  );
}
```

:::

### When NOT to use useMemo and useCallback {.unnumbered .unlisted}

Here's something that trips up a lot of developers: `useMemo` and `useCallback` aren't free. They have their own overhead, and you can actually make your app slower by overusing them.

Don't use them when:

- **The computation is already fast**: Memoizing a simple addition or string concatenation is usually not worth it
- **Dependencies change frequently**: If your dependencies change on every render, memoization provides no benefit
- **The component rarely re-renders**: If a component only renders a few times, memoization overhead isn't worth it

::: example

```jsx
// DON'T do this - premature optimization
function UserProfile({ user }) {
  // This is fast, doesn't need memoization
  const displayName = useMemo(() => {
    return `${user.firstName} ${user.lastName}`;
  }, [user.firstName, user.lastName]);

  // This callback doesn't need memoization either
  const handleClick = useCallback(() => {
    console.log('Clicked');
  }, []);

  return (
    <div onClick={handleClick}>
      <h2>{displayName}</h2>
    </div>
  );
}

// DO this instead - simple and clear
function UserProfile({ user }) {
  const displayName = `${user.firstName} ${user.lastName}`;

  const handleClick = () => {
    console.log('Clicked');
  };

  return (
    <div onClick={handleClick}>
      <h2>{displayName}</h2>
    </div>
  );
}
```

:::

::: tip
**Profile before you memoize**

Use the React DevTools Profiler to identify actual performance bottlenecks before adding memoization. Measure the performance improvement to make sure your optimization actually helps.
:::

## List rendering and keys

Rendering large lists efficiently is one of the most common React performance challenges. The key (pun intended) is understanding how React's reconciliation works and providing the right information to help it.

### The importance of keys {.unnumbered .unlisted}

When React renders a list, it needs to figure out which items are new, which have moved, and which have been removed. Keys help React match up items between renders efficiently.

::: example

```jsx
// BAD: Using array index as key
function SongList({ songs }) {
  return (
    <div>
      {songs.map((song, index) => (
        <SongCard key={index} song={song} /> // Index as key is problematic
      ))}
    </div>
  );
}

// GOOD: Using stable, unique identifier
function SongList({ songs }) {
  return (
    <div>
      {songs.map(song => (
        <SongCard key={song.id} song={song} /> // Stable ID as key
      ))}
    </div>
  );
}
```

:::

Here's why using array index as a key causes problems:

When items are added, removed, or reordered, the index-to-item mapping changes. React might think an item at index 0 is the same item when it's actually different, leading to incorrect reconciliation and potential state bugs.

### Optimizing list performance {.unnumbered .unlisted}

For large lists, consider these optimization strategies:

::: example

```jsx
// Optimize list items with memo
const SongCard = React.memo(function SongCard({ song, onPlay, onFavorite }) {
  return (
    <div className="song-card">
      <img src={song.albumArt} alt={song.album} />
      <div className="song-info">
        <h3>{song.title}</h3>
        <p>{song.artist}</p>
        <p>{formatDuration(song.duration)}</p>
      </div>
      <div className="song-actions">
        <button onClick={() => onPlay(song.id)}>Play</button>
        <button onClick={() => onFavorite(song.id)}>
          {song.isFavorite ? '[Heart]' : '[Empty Heart]'}
        </button>
      </div>
    </div>
  );
});

function OptimizedSongList({ songs }) {
  const [favorites, setFavorites] = useState(new Set());

  // Stable callback functions
  const handlePlay = useCallback((songId) => {
    // Play song logic
  }, []);

  const handleFavorite = useCallback((songId) => {
    setFavorites(prev => {
      const newFavorites = new Set(prev);
      if (newFavorites.has(songId)) {
        newFavorites.delete(songId);
      } else {
        newFavorites.add(songId);
      }
      return newFavorites;
    });
  }, []);

  // Process songs to include favorite status
  const songsWithFavorites = useMemo(() => {
    return songs.map(song => ({
      ...song,
      isFavorite: favorites.has(song.id)
    }));
  }, [songs, favorites]);

  return (
    <div className="song-list">
      {songsWithFavorites.map(song => (
        <SongCard
          key={song.id}
          song={song}
          onPlay={handlePlay}
          onFavorite={handleFavorite}
        />
      ))}
    </div>
  );
}
```

:::

## Virtual scrolling for large datasets

When you have thousands of items in a list, rendering them all at once will kill performance. Virtual scrolling (also called windowing) only renders the items currently visible on screen.

### Understanding virtual scrolling {.unnumbered .unlisted}

Virtual scrolling works by:

1. **Calculating which items are visible** based on scroll position and container height
2. **Rendering only those items** plus a few extra for smooth scrolling
3. **Using placeholder elements** to maintain correct scroll height
4. **Updating the visible range** as the user scrolls

::: example

```jsx
// Simple virtual scrolling implementation
function useVirtualScrolling({
  items,
  itemHeight,
  containerHeight,
  overscan = 5
}) {
  const [scrollTop, setScrollTop] = useState(0);
  
  const visibleRange = useMemo(() => {
    const startIndex = Math.floor(scrollTop / itemHeight);
    const endIndex = Math.min(
      startIndex + Math.ceil(containerHeight / itemHeight),
      items.length - 1
    );
    
    return {
      start: Math.max(0, startIndex - overscan),
      end: Math.min(items.length - 1, endIndex + overscan)
    };
  }, [scrollTop, itemHeight, containerHeight, items.length, overscan]);

  const visibleItems = useMemo(() => {
    return items.slice(visibleRange.start, visibleRange.end + 1).map((item, index) => ({
      ...item,
      index: visibleRange.start + index
    }));
  }, [items, visibleRange]);

  const totalHeight = items.length * itemHeight;
  const offsetY = visibleRange.start * itemHeight;

  return {
    visibleItems,
    totalHeight,
    offsetY,
    setScrollTop
  };
}

function VirtualizedSongList({ songs }) {
  const containerRef = useRef(null);
  const ITEM_HEIGHT = 80;
  const CONTAINER_HEIGHT = 400;

  const {
    visibleItems,
    totalHeight,
    offsetY,
    setScrollTop
  } = useVirtualScrolling({
    items: songs,
    itemHeight: ITEM_HEIGHT,
    containerHeight: CONTAINER_HEIGHT
  });

  const handleScroll = (e) => {
    setScrollTop(e.currentTarget.scrollTop);
  };

  return (
    <div
      ref={containerRef}
      className="virtualized-list"
      style={{ height: CONTAINER_HEIGHT, overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div style={{ transform: `translateY(${offsetY}px)` }}>
          {visibleItems.map(song => (
            <div
              key={song.id}
              style={{ height: ITEM_HEIGHT }}
              className="song-item"
            >
              <SongCard song={song} />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
```

:::

### When to use virtual scrolling {.unnumbered .unlisted}

Virtual scrolling adds complexity, so only use it when:

- **You have more than ~1000 items** in your list
- **Items have consistent height** (or you're willing to handle variable heights)
- **Users need to scroll through the entire dataset** (not just view the first page)
- **Standard pagination doesn't fit your UX** requirements

For most applications, pagination or "load more" patterns are simpler and work just as well.

## Bundle optimization and code splitting

Performance isn't just about runtime efficiency-how fast your app loads initially is equally important. Let's look at optimizing your JavaScript bundle.

### Understanding your bundle {.unnumbered .unlisted}

Before optimizing, you need to understand what's in your bundle. Tools like Webpack Bundle Analyzer can show you:

- **Which packages take up the most space**
- **Duplicate dependencies** that can be eliminated
- **Unused code** that can be removed
- **Opportunities for code splitting**

::: example

```jsx
// Install and use webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer

// Add to package.json scripts
{
  "scripts": {
    "analyze": "npm run build && npx webpack-bundle-analyzer build/static/js/*.js"
  }
}

// Run analysis
npm run analyze
```

:::

### Dynamic imports and code splitting {.unnumbered .unlisted}

Code splitting lets you split your bundle into smaller chunks that are loaded on demand. React's `Suspense` and `lazy` make this easy:

::: example

```jsx
import { Suspense, lazy } from 'react';

// Lazy load heavy components
const PracticeAnalytics = lazy(() => import('./PracticeAnalytics'));
const AdvancedSettings = lazy(() => import('./AdvancedSettings'));
const MusicTheoryTutor = lazy(() => import('./MusicTheoryTutor'));

function App() {
  const [currentView, setCurrentView] = useState('practice');

  return (
    <div className="app">
      <Navigation currentView={currentView} onViewChange={setCurrentView} />
      
      <Suspense fallback={<div className="loading">Loading...</div>}>
        {currentView === 'practice' && <PracticeSession />}
        {currentView === 'analytics' && <PracticeAnalytics />}
        {currentView === 'settings' && <AdvancedSettings />}
        {currentView === 'theory' && <MusicTheoryTutor />}
      </Suspense>
    </div>
  );
}

// You can also lazy load based on user actions
function FeatureButton() {
  const [showAdvanced, setShowAdvanced] = useState(false);

  const handleShowAdvanced = async () => {
    setShowAdvanced(true);
    // The component will be loaded when first rendered
  };

  return (
    <div>
      <button onClick={handleShowAdvanced}>
        Show Advanced Features
      </button>
      
      {showAdvanced && (
        <Suspense fallback={<div>Loading advanced features...</div>}>
          <AdvancedFeatures />
        </Suspense>
      )}
    </div>
  );
}
```

:::

### Route-based code splitting {.unnumbered .unlisted}

The most common and effective form of code splitting is splitting by routes:

::: example

```jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Suspense, lazy } from 'react';

// Lazy load route components
const Home = lazy(() => import('./pages/Home'));
const Practice = lazy(() => import('./pages/Practice'));
const Library = lazy(() => import('./pages/Library'));
const Analytics = lazy(() => import('./pages/Analytics'));
const Settings = lazy(() => import('./pages/Settings'));

// Loading component
function PageLoader() {
  return (
    <div className="page-loader">
      <div className="spinner"></div>
      <p>Loading...</p>
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <div className="app">
        <header>
          <Navigation />
        </header>
        
        <main>
          <Suspense fallback={<PageLoader />}>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/practice" element={<Practice />} />
              <Route path="/library" element={<Library />} />
              <Route path="/analytics" element={<Analytics />} />
              <Route path="/settings" element={<Settings />} />
            </Routes>
          </Suspense>
        </main>
      </div>
    </BrowserRouter>
  );
}
```

:::

## Performance monitoring and debugging

Building performant React apps isn't a one-time task-you need ongoing monitoring and debugging tools to catch performance regressions before they affect users.

### Setting up performance monitoring {.unnumbered .unlisted}

::: example

```jsx
// Custom hook for performance monitoring
function usePerformanceMonitoring() {
  const mountTime = useRef(Date.now());
  const renderCount = useRef(0);

  useEffect(() => {
    renderCount.current += 1;
  });

  useEffect(() => {
    return () => {
      const totalTime = Date.now() - mountTime.current;
      console.log(`Component unmounted after ${totalTime}ms and ${renderCount.current} renders`);
    };
  }, []);

  const logRender = useCallback((componentName) => {
    if (process.env.NODE_ENV === 'development') {
      console.log(`${componentName} rendered (render #${renderCount.current})`);
    }
  }, []);

  return { logRender };
}

// Usage in components
function ExpensiveComponent({ data }) {
  const { logRender } = usePerformanceMonitoring();
  
  useEffect(() => {
    logRender('ExpensiveComponent');
  });

  // Component logic...
  return <div>{/* Component JSX */}</div>;
}
```

:::

### Web Vitals integration {.unnumbered .unlisted}

Web Vitals are standardized metrics for measuring user experience. Here's how to track them in your React app:

::: example

```jsx
// Install web-vitals
npm install web-vitals

// Create performance monitoring utility
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics service
  console.log(metric);
  
  // Example: Send to Google Analytics
  if (window.gtag) {
    window.gtag('event', metric.name, {
      event_category: 'Web Vitals',
      value: Math.round(metric.value),
      event_label: metric.id,
      non_interaction: true,
    });
  }
}

// Initialize performance monitoring
export function initPerformanceMonitoring() {
  getCLS(sendToAnalytics);
  getFID(sendToAnalytics);
  getFCP(sendToAnalytics);
  getLCP(sendToAnalytics);
  getTTFB(sendToAnalytics);
}

// Use in your app
function App() {
  useEffect(() => {
    initPerformanceMonitoring();
  }, []);

  return (
    <div className="app">
      {/* Your app content */}
    </div>
  );
}
```

:::

## Common performance anti-patterns

Let me share some of the most common performance mistakes I see in React applications, and how to fix them.

### Anti-pattern 1: Creating objects in render {.unnumbered .unlisted}

::: example

```jsx
// BAD: Creating new objects on every render
function UserProfile({ user }) {
  return (
    <UserCard
      user={user}
      style={{ padding: 20, margin: 10 }} // New object every render!
      preferences={{ theme: 'dark', language: 'en' }} // Another new object!
    />
  );
}

// GOOD: Move objects outside render or use useMemo
const cardStyle = { padding: 20, margin: 10 };
const defaultPreferences = { theme: 'dark', language: 'en' };

function UserProfile({ user }) {
  return (
    <UserCard
      user={user}
      style={cardStyle}
      preferences={defaultPreferences}
    />
  );
}
```

:::

### Anti-pattern 2: Expensive operations in render {.unnumbered .unlisted}

::: example

```jsx
// BAD: Expensive calculation on every render
function PracticeStats({ sessions }) {
  // This runs on every render, even if sessions didn't change
  const stats = calculateComplexStats(sessions);
  
  return <StatsDisplay stats={stats} />;
}

// GOOD: Memoize expensive calculations
function PracticeStats({ sessions }) {
  const stats = useMemo(() => {
    return calculateComplexStats(sessions);
  }, [sessions]);
  
  return <StatsDisplay stats={stats} />;
}
```

:::

### Anti-pattern 3: Overusing Context {.unnumbered .unlisted}

::: example

```jsx
// BAD: Putting everything in one context
const AppContext = createContext();

function AppProvider({ children }) {
  const [user, setUser] = useState(null);
  const [songs, setSongs] = useState([]);
  const [currentSong, setCurrentSong] = useState(null);
  const [volume, setVolume] = useState(50);
  const [isPlaying, setIsPlaying] = useState(false);
  
  // When any of these change, ALL consumers re-render
  const value = {
    user, setUser,
    songs, setSongs,
    currentSong, setCurrentSong,
    volume, setVolume,
    isPlaying, setIsPlaying
  };
  
  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
}

// GOOD: Split into logical contexts
const UserContext = createContext();
const MusicLibraryContext = createContext();
const PlayerContext = createContext();

function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

function MusicLibraryProvider({ children }) {
  const [songs, setSongs] = useState([]);
  return (
    <MusicLibraryContext.Provider value={{ songs, setSongs }}>
      {children}
    </MusicLibraryContext.Provider>
  );
}

function PlayerProvider({ children }) {
  const [currentSong, setCurrentSong] = useState(null);
  const [volume, setVolume] = useState(50);
  const [isPlaying, setIsPlaying] = useState(false);
  
  return (
    <PlayerContext.Provider value={{ 
      currentSong, setCurrentSong,
      volume, setVolume,
      isPlaying, setIsPlaying 
    }}>
      {children}
    </PlayerContext.Provider>
  );
}
```

:::

## Real-world optimization case study

Let me walk you through optimizing a real-world component that initially had serious performance issues.

### The problem component {.unnumbered .unlisted}

::: example

```jsx
// Initial version - multiple performance issues
function MusicDashboard({ userId }) {
  const [user, setUser] = useState(null);
  const [songs, setSongs] = useState([]);
  const [playlists, setPlaylists] = useState([]);
  const [analytics, setAnalytics] = useState(null);
  const [recommendations, setRecommendations] = useState([]);

  // Issue 1: Multiple API calls on every render
  useEffect(() => {
    fetchUser(userId).then(setUser);
    fetchSongs(userId).then(setSongs);
    fetchPlaylists(userId).then(setPlaylists);
    fetchAnalytics(userId).then(setAnalytics);
    fetchRecommendations(userId).then(setRecommendations);
  }); // Missing dependency array!

  // Issue 2: Expensive calculation on every render
  const processedSongs = songs.map(song => ({
    ...song,
    formattedDuration: formatDuration(song.duration),
    genreColor: getGenreColor(song.genre),
    artistInfo: getArtistInfo(song.artistId) // Expensive lookup!
  }));

  // Issue 3: Creating new objects in render
  const dashboardConfig = {
    showAnalytics: true,
    showRecommendations: true,
    theme: user?.preferences?.theme || 'light'
  };

  return (
    <div className="music-dashboard">
      <UserHeader user={user} />
      
      {/* Issue 4: No memoization, re-renders on every parent update */}
      <SongList 
        songs={processedSongs} 
        config={dashboardConfig}
        onSongPlay={(song) => console.log('Playing:', song)}
      />
      
      <PlaylistGrid playlists={playlists} />
      
      {analytics && <AnalyticsPanel data={analytics} />}
      
      {recommendations.length > 0 && (
        <RecommendationList recommendations={recommendations} />
      )}
    </div>
  );
}
```

:::

### The optimized version {.unnumbered .unlisted}

::: example

```jsx
// Optimized version - addressing all performance issues
function MusicDashboard({ userId }) {
  const [user, setUser] = useState(null);
  const [songs, setSongs] = useState([]);
  const [playlists, setPlaylists] = useState([]);
  const [analytics, setAnalytics] = useState(null);
  const [recommendations, setRecommendations] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fix 1: Proper dependency array and combined loading
  useEffect(() => {
    let cancelled = false;
    
    const loadDashboardData = async () => {
      setLoading(true);
      
      try {
        // Load user data first
        const userData = await fetchUser(userId);
        if (cancelled) return;
        setUser(userData);

        // Load everything else in parallel
        const [songsData, playlistsData, analyticsData, recsData] = 
          await Promise.all([
            fetchSongs(userId),
            fetchPlaylists(userId),
            fetchAnalytics(userId),
            fetchRecommendations(userId)
          ]);

        if (cancelled) return;
        
        setSongs(songsData);
        setPlaylists(playlistsData);
        setAnalytics(analyticsData);
        setRecommendations(recsData);
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadDashboardData();

    return () => {
      cancelled = true;
    };
  }, [userId]); // Proper dependency

  // Fix 2: Memoize expensive calculations
  const processedSongs = useMemo(() => {
    return songs.map(song => ({
      ...song,
      formattedDuration: formatDuration(song.duration),
      genreColor: getGenreColor(song.genre),
      artistInfo: getArtistInfo(song.artistId)
    }));
  }, [songs]);

  // Fix 3: Memoize configuration object
  const dashboardConfig = useMemo(() => ({
    showAnalytics: true,
    showRecommendations: true,
    theme: user?.preferences?.theme || 'light'
  }), [user?.preferences?.theme]);

  // Fix 4: Stable callback function
  const handleSongPlay = useCallback((song) => {
    console.log('Playing:', song);
    // Actual play logic here
  }, []);

  if (loading) {
    return <DashboardSkeleton />;
  }

  return (
    <div className="music-dashboard">
      <MemoizedUserHeader user={user} />
      
      <MemoizedSongList 
        songs={processedSongs} 
        config={dashboardConfig}
        onSongPlay={handleSongPlay}
      />
      
      <MemoizedPlaylistGrid playlists={playlists} />
      
      {analytics && <MemoizedAnalyticsPanel data={analytics} />}
      
      {recommendations.length > 0 && (
        <MemoizedRecommendationList recommendations={recommendations} />
      )}
    </div>
  );
}

// Memoized components to prevent unnecessary re-renders
const MemoizedUserHeader = React.memo(UserHeader);
const MemoizedSongList = React.memo(SongList);
const MemoizedPlaylistGrid = React.memo(PlaylistGrid);
const MemoizedAnalyticsPanel = React.memo(AnalyticsPanel);
const MemoizedRecommendationList = React.memo(RecommendationList);
```

:::

### Results of optimization {.unnumbered .unlisted}

After these optimizations:

- **Initial load time**: Reduced from 3.2s to 1.8s (parallel loading)
- **Re-render performance**: 80% reduction in unnecessary re-renders
- **Memory usage**: Stable memory usage (fixed useEffect dependency)
- **User experience**: Smooth interactions, proper loading states

The key takeaways:

1. **Measure first**: Profile the component to identify actual bottlenecks
2. **Fix the biggest issues first**: Focus on architectural problems before micro-optimizations
3. **Test thoroughly**: Ensure optimizations don't break functionality
4. **Monitor ongoing**: Set up monitoring to catch regressions

## Chapter summary and best practices

React performance optimization is about understanding your application's bottlenecks and applying the right tools to solve them. Here are the key principles to remember:

### Performance optimization hierarchy {.unnumbered .unlisted}

1. **Architecture first**: Good component structure prevents many performance problems
2. **Measure and profile**: Use React DevTools Profiler to identify real issues
3. **Prevent unnecessary work**: Stop components from re-rendering when they don't need to
4. **Optimize expensive operations**: Use memoization for computationally expensive tasks
5. **Optimize bundle size**: Use code splitting and tree shaking to reduce initial load times
6. **Monitor continuously**: Set up performance monitoring to catch regressions

### When to optimize {.unnumbered .unlisted}

- **Profile first**: Never optimize without measuring
- **Focus on user-facing issues**: Prioritize optimizations that improve actual user experience
- **Consider maintenance cost**: Complex optimizations should provide significant benefits
- **Test thoroughly**: Ensure optimizations don't introduce bugs

### Common optimization techniques summary {.unnumbered .unlisted}

- **React.memo**: Prevent unnecessary re-renders of expensive components
- **useMemo**: Cache expensive calculations
- **useCallback**: Stabilize function references for memoized components
- **Code splitting**: Load code on demand with React.lazy and Suspense
- **Virtual scrolling**: Handle large lists efficiently
- **Bundle analysis**: Understand and optimize your JavaScript bundle

Remember, the goal isn't to apply every optimization technique-it's to solve actual performance problems that affect your users. Start with measurement, focus on the biggest issues, and always validate that your optimizations actually improve the user experience.

Performance optimization in React is an ongoing process, not a one-time task. As your application grows and evolves, new bottlenecks will emerge. The tools and techniques covered in this chapter will help you identify and solve these problems as they arise, keeping your React applications fast and responsive for your users.
