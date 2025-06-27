# Error boundaries and resilient error handling

Error boundaries represent one of React's most critical architectural patterns for building resilient applications. While error handling may not be the most exciting development topic, it distinguishes professional applications from experimental projects and ensures positive user experiences when inevitable failures occur.

Effective error handling transforms potentially catastrophic failures into manageable user experiences. Real-world applications face countless failure scenarios: network timeouts, browser inconsistencies, unexpected user interactions, and external service disruptions. Sophisticated error handling patterns prepare applications to handle these scenarios gracefully while maintaining functionality and user trust.

::: important
**Error Boundaries as Application Resilience**

Error boundaries provide React's mechanism for graceful failure handling. When components fail, error boundaries prevent application crashes by displaying fallback interfaces instead of blank screens. Advanced error handling patterns combine error boundaries with monitoring systems, retry logic, and fallback strategies to create robust error management architectures.
:::

Modern React applications require comprehensive error handling strategies that gracefully degrade functionality, provide meaningful user feedback, and maintain application stability even when individual features fail. Advanced error handling patterns integrate error boundaries with context providers, custom hooks, and monitoring systems to establish resilient error management architectures.

## Error boundary architecture fundamentals

Before exploring advanced patterns, understanding error boundary capabilities and limitations proves essential. Error boundaries catch JavaScript errors throughout child component trees, log error details, and display fallback interfaces instead of crashed component hierarchies.

::: tip
**Error Boundary Limitations**

Error boundaries do not catch errors inside event handlers, asynchronous code (e.g., `setTimeout` or `requestAnimationFrame` callbacks), or errors thrown during server-side rendering. For these scenarios, additional error handling strategies are required.
:::

## Advanced error boundary implementation patterns

Modern error boundaries extend beyond simple try-catch wrappers to provide comprehensive error management with retry logic, fallback strategies, and integrated error reporting capabilities.

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

## Implementing context-based error management

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

## Mastering asynchronous error handling

Modern React applications heavily rely on asynchronous operations, requiring sophisticated patterns for handling async errors, implementing retry logic, and managing loading states with proper error boundaries.

::: caution
**Async error handling challenges**

Error boundaries don't catch errors in async operations, event handlers, or effects. You need additional patterns to handle these scenarios effectively.
:::

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

::: tip
**Building resilient applications**

Advanced error handling patterns create resilient applications that gracefully handle failures while maintaining user experience. By combining error boundaries with context-based error management and sophisticated async error handling, you can build applications that not only survive errors but actively learn from them to improve reliability over time.
:::
