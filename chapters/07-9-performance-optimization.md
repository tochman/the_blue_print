# Performance Optimization Patterns and Strategies

Performance optimization represents a critical aspect of sophisticated React application development. These patterns enable applications to render extensive datasets efficiently, handle frequent updates without interface degradation, and maintain responsiveness under demanding user interactions and complex state changes.

Performance optimization in React requires strategic thinking and measurement-driven approaches. Effective optimization involves understanding bottlenecks, applying appropriate patterns, and maintaining the balance between performance gains and code complexity. The most impactful optimizations are often architectural decisions that prevent performance issues rather than reactive fixes.

Performance optimization should never compromise code maintainability or add unnecessary complexity. Advanced performance patterns are powerful tools that should be applied judiciously where they provide meaningful benefits. Always measure performance impacts with real metrics rather than assumptions, and validate that optimizations deliver the expected improvements.

Performance patterns must balance optimization benefits with code complexity and long-term maintainability. The most effective optimizations are often architectural decisions that prevent performance problems rather than addressing them reactively. Understanding when and how to apply different optimization techniques proves crucial for building scalable React applications.

::: important
**Measurement-Driven Optimization Philosophy**

Performance optimization should always be driven by actual measurements rather than assumptions. Advanced performance patterns are powerful tools, but they add complexity to your codebase. Apply them judiciously where they provide meaningful benefits, and always validate their impact with real performance metrics.
:::

## Virtual Scrolling and Windowing Implementation

Virtual scrolling patterns enable efficient rendering of large datasets by rendering only visible items and maintaining the illusion of complete lists through strategic positioning and event handling mechanisms.

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

## Intelligent memoization strategies

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

## Concurrent rendering optimization

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
