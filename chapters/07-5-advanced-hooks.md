# Advanced Custom Hook Patterns

Custom hooks represent the pinnacle of React's composability philosophy. While basic custom hooks provide foundational reusability, advanced custom hook patterns enable sophisticated architectural solutions that manage state machines, coordinate complex asynchronous operations, and serve as comprehensive abstraction layers for application logic.

The true power of custom hooks emerges through their composability and architectural flexibility. Unlike higher-order components or render props, hooks integrate seamlessly, test in isolation, and provide clear interfaces for the logic they encapsulate. As applications scale in complexity, mastering advanced hook patterns becomes essential for maintaining clean, maintainable codebases.

::: important
**Hooks as Architectural Boundaries**

Advanced custom hooks function as more than state management tools—they serve as architectural boundaries that encapsulate business logic, coordinate side effects, and provide stable interfaces between components and complex application concerns. Well-designed hooks can eliminate the need for external state management libraries in many scenarios.
:::

## State Machine Patterns with Custom Hooks

Complex user interactions often benefit from explicit state machine modeling. Custom hooks can encapsulate state machines that manage intricate workflows with clearly defined state transitions and coordinated side effects.

::: example
```jsx
import { useState, useCallback, useRef, useEffect } from 'react';

// Practice session state machine hook
function usePracticeSessionStateMachine(initialSession = null) {
  const [state, setState] = useState('idle');
  const [session, setSession] = useState(initialSession);
  const [error, setError] = useState(null);
  const [progress, setProgress] = useState(0);
  
  const timerRef = useRef(null);
  const startTimeRef = useRef(null);

  // State machine transitions
  const transitions = {
    idle: ['preparing', 'error'],
    preparing: ['active', 'error', 'idle'],
    active: ['paused', 'completed', 'error'],
    paused: ['active', 'completed', 'error'],
    completed: ['idle'],
    error: ['idle', 'preparing']
  };

  const canTransition = useCallback((fromState, toState) => {
    return transitions[fromState]?.includes(toState) || false;
  }, []);

  const transition = useCallback((newState, payload = {}) => {
    if (!canTransition(state, newState)) {
      console.warn(`Invalid transition from ${state} to ${newState}`);
      return false;
    }

    setState(newState);
    
    // Handle side effects based on state transitions
    switch (newState) {
      case 'preparing':
        setError(null);
        setProgress(0);
        break;
        
      case 'active':
        startTimeRef.current = Date.now();
        timerRef.current = setInterval(() => {
          setProgress(prev => {
            const elapsed = Date.now() - startTimeRef.current;
            const targetDuration = session?.targetDuration || 1800000; // 30 minutes
            return Math.min((elapsed / targetDuration) * 100, 100);
          });
        }, 1000);
        break;
        
      case 'paused':
      case 'completed':
      case 'error':
        if (timerRef.current) {
          clearInterval(timerRef.current);
          timerRef.current = null;
        }
        break;
    }

    return true;
  }, [state, session, canTransition]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    };
  }, []);

  // Public API
  const startSession = useCallback((sessionData) => {
    setSession(sessionData);
    return transition('preparing') && transition('active');
  }, [transition]);

  const pauseSession = useCallback(() => {
    return transition('paused');
  }, [transition]);

  const resumeSession = useCallback(() => {
    return transition('active');
  }, [transition]);

  const completeSession = useCallback(() => {
    return transition('completed');
  }, [transition]);

  const resetSession = useCallback(() => {
    setSession(null);
    setProgress(0);
    setError(null);
    return transition('idle');
  }, [transition]);

  const handleError = useCallback((errorMessage) => {
    setError(errorMessage);
    return transition('error');
  }, [transition]);

  return {
    state,
    session,
    error,
    progress,
    canTransition: (toState) => canTransition(state, toState),
    startSession,
    pauseSession,
    resumeSession,
    completeSession,
    resetSession,
    handleError,
    isIdle: state === 'idle',
    isPreparing: state === 'preparing',
    isActive: state === 'active',
    isPaused: state === 'paused',
    isCompleted: state === 'completed',
    hasError: state === 'error'
  };
}
```
:::

This state machine hook provides a robust foundation for managing complex practice session workflows with clear state transitions and side effect management.

## Advanced Data Synchronization and Caching Strategies

Modern applications require sophisticated data coordination from multiple sources while maintaining consistency and optimal performance. Custom hooks can provide advanced caching and synchronization strategies that handle complex data flows seamlessly.

::: example
```jsx
// Advanced data synchronization hook with caching
function useDataSync(sources, options = {}) {
  const {
    cacheTimeout = 300000, // 5 minutes
    retryAttempts = 3,
    retryDelay = 1000,
    onError,
    onSuccess
  } = options;

  const [data, setData] = useState(new Map());
  const [loading, setLoading] = useState(new Set());
  const [errors, setErrors] = useState(new Map());
  const cache = useRef(new Map());
  const retryTimeouts = useRef(new Map());

  const isStale = useCallback((sourceId) => {
    const cached = cache.current.get(sourceId);
    if (!cached) return true;
    return Date.now() - cached.timestamp > cacheTimeout;
  }, [cacheTimeout]);

  const fetchSource = useCallback(async (sourceId, source, attempt = 1) => {
    setLoading(prev => new Set([...prev, sourceId]));
    setErrors(prev => {
      const newErrors = new Map(prev);
      newErrors.delete(sourceId);
      return newErrors;
    });

    try {
      const result = await source.fetch();
      
      // Cache the result
      cache.current.set(sourceId, {
        data: result,
        timestamp: Date.now()
      });

      setData(prev => new Map([...prev, [sourceId, result]]));
      onSuccess?.(sourceId, result);
      
    } catch (error) {
      if (attempt < retryAttempts) {
        // Schedule retry
        const timeoutId = setTimeout(() => {
          fetchSource(sourceId, source, attempt + 1);
        }, retryDelay * attempt);
        
        retryTimeouts.current.set(sourceId, timeoutId);
      } else {
        setErrors(prev => new Map([...prev, [sourceId, error]]));
        onError?.(sourceId, error);
      }
    } finally {
      setLoading(prev => {
        const newLoading = new Set(prev);
        newLoading.delete(sourceId);
        return newLoading;
      });
    }
  }, [retryAttempts, retryDelay, onError, onSuccess]);

  const syncData = useCallback(() => {
    Object.entries(sources).forEach(([sourceId, source]) => {
      if (isStale(sourceId)) {
        fetchSource(sourceId, source);
      } else {
        // Use cached data
        const cached = cache.current.get(sourceId);
        setData(prev => new Map([...prev, [sourceId, cached.data]]));
      }
    });
  }, [sources, isStale, fetchSource]);

  // Initial sync and periodic refresh
  useEffect(() => {
    syncData();
    
    const interval = setInterval(syncData, cacheTimeout);
    return () => clearInterval(interval);
  }, [syncData, cacheTimeout]);

  // Cleanup retry timeouts
  useEffect(() => {
    return () => {
      retryTimeouts.current.forEach(timeoutId => clearTimeout(timeoutId));
    };
  }, []);

  const refetch = useCallback((sourceId) => {
    if (sourceId) {
      cache.current.delete(sourceId);
      const source = sources[sourceId];
      if (source) {
        fetchSource(sourceId, source);
      }
    } else {
      cache.current.clear();
      syncData();
    }
  }, [sources, fetchSource, syncData]);

  return {
    data: Object.fromEntries(data),
    loading: Array.from(loading),
    errors: Object.fromEntries(errors),
    refetch,
    isLoading: loading.size > 0,
    hasErrors: errors.size > 0
  };
}

// Usage example
function PracticeStatsDashboard({ userId }) {
  const dataSources = {
    sessions: {
      fetch: () => PracticeAPI.getSessions(userId)
    },
    progress: {
      fetch: () => PracticeAPI.getProgress(userId)
    },
    goals: {
      fetch: () => PracticeAPI.getGoals(userId)
    }
  };

  const { data, loading, errors, refetch } = useDataSync(dataSources, {
    cacheTimeout: 600000, // 10 minutes
    onError: (sourceId, error) => {
      console.error(`Failed to fetch ${sourceId}:`, error);
    }
  });

  return (
    <div className="practice-stats">
      {loading.includes('sessions') ? (
        <div>Loading sessions...</div>
      ) : (
        <SessionStats sessions={data.sessions} />
      )}
      
      {data.progress && <ProgressChart data={data.progress} />}
      {data.goals && <GoalTracker goals={data.goals} />}
      
      <button onClick={() => refetch()}>Refresh All</button>
    </div>
  );
}
```
:::

## Async Coordination and Effect Management

Complex applications often need to coordinate multiple asynchronous operations with sophisticated error handling and dependency management.

::: example
```jsx
// Advanced async coordination hook
function useAsyncCoordinator() {
  const [operations, setOperations] = useState(new Map());
  const pendingOperations = useRef(new Map());

  const registerOperation = useCallback((id, operation, dependencies = []) => {
    const operationState = {
      id,
      operation,
      dependencies,
      status: 'pending',
      result: null,
      error: null,
      startTime: null,
      endTime: null
    };

    setOperations(prev => new Map([...prev, [id, operationState]]));
    return id;
  }, []);

  const executeOperation = useCallback(async (id) => {
    const operation = operations.get(id);
    if (!operation) return;

    // Check if dependencies are completed
    const uncompletedDeps = operation.dependencies.filter(depId => {
      const dep = operations.get(depId);
      return !dep || dep.status !== 'completed';
    });

    if (uncompletedDeps.length > 0) {
      console.warn(`Operation ${id} has uncompleted dependencies:`, uncompletedDeps);
      return;
    }

    setOperations(prev => {
      const newOps = new Map(prev);
      const updatedOp = { ...operation, status: 'running', startTime: Date.now() };
      newOps.set(id, updatedOp);
      return newOps;
    });

    try {
      const dependencyResults = operation.dependencies.reduce((acc, depId) => {
        const dep = operations.get(depId);
        acc[depId] = dep?.result;
        return acc;
      }, {});

      const result = await operation.operation(dependencyResults);

      setOperations(prev => {
        const newOps = new Map(prev);
        const completedOp = {
          ...newOps.get(id),
          status: 'completed',
          result,
          endTime: Date.now()
        };
        newOps.set(id, completedOp);
        return newOps;
      });

      return result;
    } catch (error) {
      setOperations(prev => {
        const newOps = new Map(prev);
        const errorOp = {
          ...newOps.get(id),
          status: 'error',
          error,
          endTime: Date.now()
        };
        newOps.set(id, errorOp);
        return newOps;
      });

      throw error;
    }
  }, [operations]);

  const executeAll = useCallback(async () => {
    const sortedOps = topologicalSort(Array.from(operations.keys()), operations);
    const results = {};

    for (const opId of sortedOps) {
      try {
        results[opId] = await executeOperation(opId);
      } catch (error) {
        console.error(`Operation ${opId} failed:`, error);
      }
    }

    return results;
  }, [operations, executeOperation]);

  const reset = useCallback(() => {
    setOperations(new Map());
    pendingOperations.current.clear();
  }, []);

  return {
    registerOperation,
    executeOperation,
    executeAll,
    reset,
    operations: Array.from(operations.values()),
    isComplete: Array.from(operations.values()).every(op => 
      op.status === 'completed' || op.status === 'error'
    )
  };
}

// Usage example for complex practice session initialization
function usePracticeSessionInitialization(sessionConfig) {
  const coordinator = useAsyncCoordinator();
  const [initializationState, setInitializationState] = useState('idle');

  const initializeSession = useCallback(async () => {
    setInitializationState('initializing');

    try {
      // Register dependent operations
      const validateConfigId = coordinator.registerOperation(
        'validateConfig',
        async () => validateSessionConfig(sessionConfig)
      );

      const loadResourcesId = coordinator.registerOperation(
        'loadResources',
        async ({ validateConfig }) => loadSessionResources(validateConfig),
        ['validateConfig']
      );

      const setupAudioId = coordinator.registerOperation(
        'setupAudio',
        async ({ loadResources }) => setupAudioContext(loadResources.audioFiles),
        ['loadResources']
      );

      const initializeTimerId = coordinator.registerOperation(
        'initializeTimer',
        async ({ validateConfig }) => initializeSessionTimer(validateConfig.duration),
        ['validateConfig']
      );

      // Execute all operations
      const results = await coordinator.executeAll();
      
      setInitializationState('completed');
      return results;
    } catch (error) {
      setInitializationState('error');
      throw error;
    }
  }, [sessionConfig, coordinator]);

  return {
    initializeSession,
    initializationState,
    operations: coordinator.operations,
    reset: coordinator.reset
  };
}
```
:::

## Resource Management and Cleanup Patterns

Advanced hooks often need to manage complex resources with sophisticated cleanup strategies to prevent memory leaks and resource contention.

::: example
```jsx
// Advanced resource management hook
function useResourceManager() {
  const resources = useRef(new Map());
  const cleanupFunctions = useRef(new Map());

  const registerResource = useCallback((id, resource, cleanup) => {
    // Clean up existing resource if it exists
    if (resources.current.has(id)) {
      releaseResource(id);
    }

    resources.current.set(id, resource);
    if (cleanup) {
      cleanupFunctions.current.set(id, cleanup);
    }

    return resource;
  }, []);

  const releaseResource = useCallback((id) => {
    const cleanup = cleanupFunctions.current.get(id);
    if (cleanup) {
      try {
        cleanup();
      } catch (error) {
        console.error(`Error cleaning up resource ${id}:`, error);
      }
    }

    resources.current.delete(id);
    cleanupFunctions.current.delete(id);
  }, []);

  const getResource = useCallback((id) => {
    return resources.current.get(id);
  }, []);

  const releaseAll = useCallback(() => {
    resources.current.forEach((_, id) => releaseResource(id));
  }, [releaseResource]);

  // Cleanup on unmount
  useEffect(() => {
    return () => releaseAll();
  }, [releaseAll]);

  return {
    registerResource,
    releaseResource,
    getResource,
    releaseAll,
    resourceCount: resources.current.size
  };
}

// Specialized hook for practice session resources
function usePracticeSessionResources() {
  const resourceManager = useResourceManager();
  const [resourceState, setResourceState] = useState({});

  const loadAudioResource = useCallback(async (audioUrl) => {
    try {
      const audio = new Audio(audioUrl);
      
      // Wait for audio to be ready
      await new Promise((resolve, reject) => {
        audio.addEventListener('canplaythrough', resolve);
        audio.addEventListener('error', reject);
        audio.load();
      });

      resourceManager.registerResource('audio', audio, () => {
        audio.pause();
        audio.src = '';
      });

      setResourceState(prev => ({ ...prev, audioLoaded: true }));
      return audio;
    } catch (error) {
      setResourceState(prev => ({ ...prev, audioError: error.message }));
      throw error;
    }
  }, [resourceManager]);

  const loadMetronomeResource = useCallback(async () => {
    try {
      const metronome = new MetronomeEngine();
      await metronome.initialize();

      resourceManager.registerResource('metronome', metronome, () => {
        metronome.stop();
        metronome.destroy();
      });

      setResourceState(prev => ({ ...prev, metronomeLoaded: true }));
      return metronome;
    } catch (error) {
      setResourceState(prev => ({ ...prev, metronomeError: error.message }));
      throw error;
    }
  }, [resourceManager]);

  const getAudio = useCallback(() => {
    return resourceManager.getResource('audio');
  }, [resourceManager]);

  const getMetronome = useCallback(() => {
    return resourceManager.getResource('metronome');
  }, [resourceManager]);

  return {
    loadAudioResource,
    loadMetronomeResource,
    getAudio,
    getMetronome,
    releaseAll: resourceManager.releaseAll,
    resourceState
  };
}
```
:::

## Composable Hook Factories

Advanced patterns often involve creating hooks that generate other hooks, providing flexible abstractions for common patterns.

::: example
```jsx
// Factory for creating data management hooks
function createDataHook(config) {
  const {
    endpoint,
    transform = data => data,
    cacheKey,
    dependencies = [],
    onError,
    onSuccess
  } = config;

  return function useData(...params) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchData = useCallback(async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await fetch(endpoint(...params));
        const rawData = await response.json();
        const transformedData = transform(rawData);
        
        setData(transformedData);
        onSuccess?.(transformedData);
      } catch (err) {
        setError(err);
        onError?.(err);
      } finally {
        setLoading(false);
      }
    }, params);

    useEffect(() => {
      fetchData();
    }, [fetchData, ...dependencies]);

    return {
      data,
      loading,
      error,
      refetch: fetchData
    };
  };
}

// Factory usage
const usePracticeSessions = createDataHook({
  endpoint: (userId) => `/api/users/${userId}/sessions`,
  transform: (sessions) => sessions.map(session => ({
    ...session,
    date: new Date(session.date),
    duration: session.duration * 60 // Convert to seconds
  })),
  cacheKey: 'practice-sessions'
});

const useSessionAnalytics = createDataHook({
  endpoint: (userId, dateRange) => `/api/users/${userId}/analytics?${dateRange}`,
  transform: (analytics) => ({
    ...analytics,
    averageSession: analytics.totalTime / analytics.sessionCount
  })
});

// Hook composition factory
function createCompositeHook(...hookFactories) {
  return function useComposite(...params) {
    const results = hookFactories.map(factory => factory(...params));
    
    return results.reduce((acc, result, index) => {
      acc[`hook${index}`] = result;
      return acc;
    }, {
      loading: results.some(r => r.loading),
      error: results.find(r => r.error)?.error,
      refetchAll: () => results.forEach(r => r.refetch?.())
    });
  };
}
```
:::

These advanced hook patterns provide powerful abstractions that can significantly improve code organization, reusability, and maintainability in complex React applications. They represent the evolution of React's compositional model and demonstrate how hooks can serve as architectural foundations for sophisticated applications.
