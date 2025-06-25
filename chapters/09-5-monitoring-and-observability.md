# Monitoring and Observability

Production React applications require comprehensive monitoring and observability systems that provide real-time insights into application performance, user experience, and operational health. Modern observability extends beyond basic uptime monitoring—it encompasses application performance monitoring (APM), error tracking, user behavior analytics, and infrastructure monitoring that enable proactive issue resolution and data-driven optimization decisions.

Effective monitoring systems combine multiple data sources to create complete visibility into application behavior, from frontend user interactions to backend service dependencies. Professional observability implementation enables teams to detect issues before they impact users, understand performance bottlenecks, and continuously optimize application delivery.

This section provides comprehensive guidance for implementing production-grade monitoring and observability systems that support reliable React application operations and continuous improvement processes.

::: important
**Observability Philosophy**

Implement observability systems that provide actionable insights rather than overwhelming teams with data. Every metric, log, and alert should contribute to understanding system behavior and enabling informed decisions. The goal is comprehensive visibility that supports rapid issue resolution and continuous optimization while minimizing operational overhead and alert fatigue.
:::

## Application Performance Monitoring (APM)

APM systems provide real-time insights into React application performance, user experience metrics, and resource utilization patterns.

### Real User Monitoring (RUM)

Implement comprehensive user experience monitoring:

::: example
**Advanced RUM Implementation**

```javascript
// src/monitoring/performance.js
class PerformanceMonitor {
  constructor() {
    this.metrics = new Map()
    this.observers = new Map()
    this.initialized = false
  }

  init() {
    if (this.initialized || typeof window === 'undefined') return
    
    this.setupPerformanceObservers()
    this.trackCoreWebVitals()
    this.monitorResourceTiming()
    this.trackUserInteractions()
    this.initialized = true
  }

  setupPerformanceObservers() {
    // Navigation timing
    if ('PerformanceObserver' in window) {
      const navObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries()
        entries.forEach(entry => {
          this.recordNavigationTiming(entry)
        })
      })
      
      navObserver.observe({ entryTypes: ['navigation'] })
      this.observers.set('navigation', navObserver)

      // Paint timing
      const paintObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries()
        entries.forEach(entry => {
          this.recordPaintTiming(entry)
        })
      })
      
      paintObserver.observe({ entryTypes: ['paint'] })
      this.observers.set('paint', paintObserver)

      // Largest Contentful Paint
      const lcpObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries()
        const lastEntry = entries[entries.length - 1]
        this.recordMetric('lcp', lastEntry.startTime)
      })
      
      lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] })
      this.observers.set('lcp', lcpObserver)
    }
  }

  trackCoreWebVitals() {
    // First Input Delay (FID)
    if ('PerformanceEventTiming' in window) {
      const fidObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries()
        entries.forEach(entry => {
          if (entry.name === 'first-input') {
            const fid = entry.processingStart - entry.startTime
            this.recordMetric('fid', fid)
          }
        })
      })
      
      fidObserver.observe({ entryTypes: ['first-input'] })
      this.observers.set('fid', fidObserver)
    }

    // Cumulative Layout Shift (CLS)
    let clsScore = 0
    const clsObserver = new PerformanceObserver((list) => {
      const entries = list.getEntries()
      entries.forEach(entry => {
        if (!entry.hadRecentInput) {
          clsScore += entry.value
        }
      })
      this.recordMetric('cls', clsScore)
    })
    
    clsObserver.observe({ entryTypes: ['layout-shift'] })
    this.observers.set('cls', clsObserver)
  }

  monitorResourceTiming() {
    const resourceObserver = new PerformanceObserver((list) => {
      const entries = list.getEntries()
      entries.forEach(entry => {
        this.recordResourceTiming(entry)
      })
    })
    
    resourceObserver.observe({ entryTypes: ['resource'] })
    this.observers.set('resource', resourceObserver)
  }

  trackUserInteractions() {
    // Track route changes
    const originalPushState = history.pushState
    const originalReplaceState = history.replaceState

    history.pushState = (...args) => {
      this.recordRouteChange(args[2])
      return originalPushState.apply(history, args)
    }

    history.replaceState = (...args) => {
      this.recordRouteChange(args[2])
      return originalReplaceState.apply(history, args)
    }

    // Track long tasks
    if ('PerformanceObserver' in window) {
      const longTaskObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries()
        entries.forEach(entry => {
          this.recordLongTask(entry)
        })
      })
      
      longTaskObserver.observe({ entryTypes: ['longtask'] })
      this.observers.set('longtask', longTaskObserver)
    }
  }

  recordNavigationTiming(entry) {
    const timing = {
      dns: entry.domainLookupEnd - entry.domainLookupStart,
      tcp: entry.connectEnd - entry.connectStart,
      ssl: entry.secureConnectionStart > 0 ? 
           entry.connectEnd - entry.secureConnectionStart : 0,
      ttfb: entry.responseStart - entry.requestStart,
      download: entry.responseEnd - entry.responseStart,
      domParse: entry.domContentLoadedEventStart - entry.responseEnd,
      domReady: entry.domContentLoadedEventEnd - entry.domContentLoadedEventStart,
      loadComplete: entry.loadEventEnd - entry.loadEventStart,
      total: entry.loadEventEnd - entry.fetchStart
    }

    this.sendMetric('navigation_timing', timing)
  }

  recordPaintTiming(entry) {
    this.recordMetric(entry.name.replace('-', '_'), entry.startTime)
  }

  recordResourceTiming(entry) {
    const resource = {
      name: entry.name,
      type: entry.initiatorType,
      duration: entry.duration,
      size: entry.transferSize,
      cached: entry.transferSize === 0 && entry.decodedBodySize > 0
    }

    this.sendMetric('resource_timing', resource)
  }

  recordRouteChange(url) {
    const routeMetric = {
      url,
      timestamp: Date.now(),
      loadTime: performance.now()
    }

    this.sendMetric('route_change', routeMetric)
  }

  recordLongTask(entry) {
    const longTask = {
      duration: entry.duration,
      startTime: entry.startTime,
      attribution: entry.attribution
    }

    this.sendMetric('long_task', longTask)
  }

  recordMetric(name, value) {
    this.metrics.set(name, value)
    this.sendMetric(name, value)
  }

  sendMetric(name, data) {
    // Send to analytics service
    if (window.gtag) {
      window.gtag('event', name, {
        custom_parameter: data,
        event_category: 'performance'
      })
    }

    // Send to custom analytics endpoint
    this.sendToAnalytics(name, data)
  }

  async sendToAnalytics(eventName, data) {
    try {
      await fetch('/api/analytics', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          event: eventName,
          data,
          timestamp: Date.now(),
          url: window.location.href,
          userAgent: navigator.userAgent,
          sessionId: this.getSessionId()
        })
      })
    } catch (error) {
      console.warn('Analytics send failed:', error)
    }
  }

  getSessionId() {
    let sessionId = sessionStorage.getItem('analytics_session')
    if (!sessionId) {
      sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      sessionStorage.setItem('analytics_session', sessionId)
    }
    return sessionId
  }

  disconnect() {
    this.observers.forEach(observer => observer.disconnect())
    this.observers.clear()
    this.metrics.clear()
  }
}

export const performanceMonitor = new PerformanceMonitor()
```
:::

### Component Performance Tracking

Monitor React component performance and rendering patterns:

::: example
**React Component Performance Monitoring**

```javascript
// src/monitoring/componentMonitor.js
import { Profiler } from 'react'

class ComponentPerformanceTracker {
  constructor() {
    this.renderTimes = new Map()
    this.componentCounts = new Map()
    this.slowComponents = new Set()
  }

  onRenderCallback = (id, phase, actualDuration, baseDuration, startTime, commitTime) => {
    const renderData = {
      id,
      phase,
      actualDuration,
      baseDuration,
      startTime,
      commitTime,
      timestamp: Date.now()
    }

    this.recordRenderTime(renderData)
    this.detectSlowComponents(renderData)
    this.sendRenderMetrics(renderData)
  }

  recordRenderTime(renderData) {
    const { id, actualDuration } = renderData
    
    if (!this.renderTimes.has(id)) {
      this.renderTimes.set(id, [])
    }
    
    const times = this.renderTimes.get(id)
    times.push(actualDuration)
    
    // Keep only last 100 renders per component
    if (times.length > 100) {
      times.shift()
    }

    // Update component render count
    const count = this.componentCounts.get(id) || 0
    this.componentCounts.set(id, count + 1)
  }

  detectSlowComponents(renderData) {
    const { id, actualDuration } = renderData
    const threshold = 16 // 16ms threshold for 60fps
    
    if (actualDuration > threshold) {
      this.slowComponents.add(id)
      console.warn(`Slow component detected: ${id} took ${actualDuration.toFixed(2)}ms to render`)
    }
  }

  sendRenderMetrics(renderData) {
    // Send to monitoring service
    if (window.performanceMonitor) {
      window.performanceMonitor.sendMetric('component_render', renderData)
    }
  }

  getComponentStats(componentId) {
    const times = this.renderTimes.get(componentId) || []
    if (times.length === 0) return null

    const sorted = [...times].sort((a, b) => a - b)
    const sum = times.reduce((acc, time) => acc + time, 0)

    return {
      count: this.componentCounts.get(componentId) || 0,
      average: sum / times.length,
      median: sorted[Math.floor(sorted.length / 2)],
      p95: sorted[Math.floor(sorted.length * 0.95)],
      max: Math.max(...times),
      min: Math.min(...times),
      isSlow: this.slowComponents.has(componentId)
    }
  }

  getAllStats() {
    const stats = {}
    for (const [componentId] of this.renderTimes) {
      stats[componentId] = this.getComponentStats(componentId)
    }
    return stats
  }

  reset() {
    this.renderTimes.clear()
    this.componentCounts.clear()
    this.slowComponents.clear()
  }
}

export const componentTracker = new ComponentPerformanceTracker()

// HOC for component performance monitoring
export function withPerformanceMonitoring(WrappedComponent, componentName) {
  const MonitoredComponent = (props) => (
    <Profiler id={componentName || WrappedComponent.name} onRender={componentTracker.onRenderCallback}>
      <WrappedComponent {...props} />
    </Profiler>
  )

  MonitoredComponent.displayName = `withPerformanceMonitoring(${componentName || WrappedComponent.name})`
  return MonitoredComponent
}

// Hook for manual performance tracking
export function usePerformanceTracking(componentName) {
  const startTime = useRef(null)
  
  useEffect(() => {
    startTime.current = performance.now()
    
    return () => {
      if (startTime.current) {
        const duration = performance.now() - startTime.current
        componentTracker.sendRenderMetrics({
          id: componentName,
          phase: 'unmount',
          actualDuration: duration,
          timestamp: Date.now()
        })
      }
    }
  }, [componentName])

  const trackEvent = useCallback((eventName, data = {}) => {
    componentTracker.sendRenderMetrics({
      id: componentName,
      phase: 'event',
      eventName,
      data,
      timestamp: Date.now()
    })
  }, [componentName])

  return { trackEvent }
}
```
:::

## Error Tracking and Monitoring

Implement comprehensive error tracking systems that capture, categorize, and alert on application errors.

### Advanced Error Boundary Implementation

Create robust error boundaries with detailed error reporting:

::: example
**Production Error Boundary System**

```javascript
// src/monitoring/ErrorBoundary.js
import React from 'react'
import * as Sentry from '@sentry/react'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      errorId: null
    }
  }

  static getDerivedStateFromError(error) {
    return {
      hasError: true,
      error
    }
  }

  componentDidCatch(error, errorInfo) {
    const errorId = this.generateErrorId()
    
    this.setState({
      errorInfo,
      errorId
    })

    // Log error details
    this.logError(error, errorInfo, errorId)
    
    // Send to error tracking service
    this.reportError(error, errorInfo, errorId)
    
    // Notify monitoring systems
    this.notifyMonitoring(error, errorInfo, errorId)
  }

  generateErrorId() {
    return `error_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  logError(error, errorInfo, errorId) {
    const errorLog = {
      errorId,
      message: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
      props: this.props,
      url: window.location.href,
      userAgent: navigator.userAgent,
      timestamp: new Date().toISOString(),
      userId: this.getUserId(),
      sessionId: this.getSessionId()
    }

    console.error('Error Boundary caught an error:', errorLog)
    
    // Store error locally for debugging
    this.storeErrorLocally(errorLog)
  }

  reportError(error, errorInfo, errorId) {
    // Send to Sentry
    Sentry.withScope((scope) => {
      scope.setTag('errorBoundary', this.props.name || 'Unknown')
      scope.setTag('errorId', errorId)
      scope.setLevel('error')
      scope.setContext('errorInfo', errorInfo)
      scope.setContext('props', this.props)
      Sentry.captureException(error)
    })

    // Send to custom error tracking
    this.sendToErrorService(error, errorInfo, errorId)
  }

  async sendToErrorService(error, errorInfo, errorId) {
    try {
      await fetch('/api/errors', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          errorId,
          message: error.message,
          stack: error.stack,
          componentStack: errorInfo.componentStack,
          url: window.location.href,
          userAgent: navigator.userAgent,
          timestamp: Date.now(),
          userId: this.getUserId(),
          sessionId: this.getSessionId(),
          buildVersion: process.env.REACT_APP_VERSION,
          environment: process.env.NODE_ENV
        })
      })
    } catch (fetchError) {
      console.error('Failed to report error:', fetchError)
    }
  }

  notifyMonitoring(error, errorInfo, errorId) {
    // Send to performance monitoring
    if (window.performanceMonitor) {
      window.performanceMonitor.sendMetric('error_boundary_triggered', {
        errorId,
        component: this.props.name,
        message: error.message
      })
    }

    // Trigger alerts for critical errors
    if (this.isCriticalError(error)) {
      this.triggerCriticalAlert(error, errorId)
    }
  }

  isCriticalError(error) {
    const criticalPatterns = [
      /ChunkLoadError/,
      /Loading chunk \d+ failed/,
      /Network Error/,
      /Failed to fetch/
    ]
    
    return criticalPatterns.some(pattern => pattern.test(error.message))
  }

  async triggerCriticalAlert(error, errorId) {
    try {
      await fetch('/api/alerts/critical', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          type: 'critical_error',
          errorId,
          message: error.message,
          timestamp: Date.now()
        })
      })
    } catch (alertError) {
      console.error('Failed to send critical alert:', alertError)
    }
  }

  storeErrorLocally(errorLog) {
    try {
      const existingErrors = JSON.parse(localStorage.getItem('app_errors') || '[]')
      existingErrors.push(errorLog)
      
      // Keep only last 10 errors
      if (existingErrors.length > 10) {
        existingErrors.shift()
      }
      
      localStorage.setItem('app_errors', JSON.stringify(existingErrors))
    } catch (storageError) {
      console.warn('Failed to store error locally:', storageError)
    }
  }

  getUserId() {
    // Get user ID from authentication context or localStorage
    return localStorage.getItem('userId') || 'anonymous'
  }

  getSessionId() {
    let sessionId = sessionStorage.getItem('sessionId')
    if (!sessionId) {
      sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      sessionStorage.setItem('sessionId', sessionId)
    }
    return sessionId
  }

  handleRetry = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
      errorId: null
    })
  }

  render() {
    if (this.state.hasError) {
      const { fallback: Fallback, name } = this.props
      
      if (Fallback) {
        return (
          <Fallback
            error={this.state.error}
            errorInfo={this.state.errorInfo}
            errorId={this.state.errorId}
            onRetry={this.handleRetry}
          />
        )
      }

      return (
        <div className="error-boundary">
          <div className="error-boundary__content">
            <h2>Something went wrong</h2>
            <p>We're sorry, but something unexpected happened.</p>
            <details className="error-boundary__details">
              <summary>Error Details (ID: {this.state.errorId})</summary>
              <pre>{this.state.error?.message}</pre>
            </details>
            <div className="error-boundary__actions">
              <button onClick={this.handleRetry}>Try Again</button>
              <button onClick={() => window.location.reload()}>Reload Page</button>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary

// Enhanced error boundary with Sentry integration
export const SentryErrorBoundary = Sentry.withErrorBoundary(ErrorBoundary, {
  fallback: ({ error, resetError }) => (
    <div className="error-boundary">
      <h2>Application Error</h2>
      <p>An unexpected error occurred: {error.message}</p>
      <button onClick={resetError}>Try again</button>
    </div>
  )
})
```
:::

### Unhandled Error Monitoring

Capture and report unhandled errors and promise rejections:

::: example
**Global Error Monitoring Setup**

```javascript
// src/monitoring/globalErrorHandler.js
class GlobalErrorHandler {
  constructor() {
    this.errorQueue = []
    this.isProcessing = false
    this.maxQueueSize = 50
    this.batchSize = 10
    this.batchTimeout = 5000
  }

  init() {
    // Capture unhandled JavaScript errors
    window.addEventListener('error', this.handleError.bind(this))
    
    // Capture unhandled promise rejections
    window.addEventListener('unhandledrejection', this.handlePromiseRejection.bind(this))
    
    // Capture React errors (if not caught by error boundaries)
    this.setupReactErrorHandler()
    
    // Start processing error queue
    this.startErrorProcessing()
  }

  handleError(event) {
    const error = {
      type: 'javascript_error',
      message: event.message,
      filename: event.filename,
      lineno: event.lineno,
      colno: event.colno,
      stack: event.error?.stack,
      timestamp: Date.now(),
      url: window.location.href,
      userAgent: navigator.userAgent
    }

    this.queueError(error)
  }

  handlePromiseRejection(event) {
    const error = {
      type: 'unhandled_promise_rejection',
      message: event.reason?.message || 'Unhandled promise rejection',
      stack: event.reason?.stack,
      reason: event.reason,
      timestamp: Date.now(),
      url: window.location.href,
      userAgent: navigator.userAgent
    }

    this.queueError(error)
    
    // Prevent the default browser behavior
    event.preventDefault()
  }

  setupReactErrorHandler() {
    // Override console.error to catch React errors
    const originalConsoleError = console.error
    console.error = (...args) => {
      const message = args.join(' ')
      
      // Check if this is a React error
      if (message.includes('React') || message.includes('Warning:')) {
        const error = {
          type: 'react_error',
          message,
          timestamp: Date.now(),
          url: window.location.href,
          userAgent: navigator.userAgent
        }
        
        this.queueError(error)
      }
      
      // Call original console.error
      originalConsoleError.apply(console, args)
    }
  }

  queueError(error) {
    // Add additional context
    error.sessionId = this.getSessionId()
    error.userId = this.getUserId()
    error.buildVersion = process.env.REACT_APP_VERSION
    error.environment = process.env.NODE_ENV

    // Add to queue
    this.errorQueue.push(error)
    
    // Trim queue if too large
    if (this.errorQueue.length > this.maxQueueSize) {
      this.errorQueue.shift()
    }

    // Process immediately for critical errors
    if (this.isCriticalError(error)) {
      this.processErrorBatch([error])
    }
  }

  startErrorProcessing() {
    setInterval(() => {
      this.processErrorQueue()
    }, this.batchTimeout)
  }

  processErrorQueue() {
    if (this.errorQueue.length === 0 || this.isProcessing) {
      return
    }

    const batch = this.errorQueue.splice(0, this.batchSize)
    this.processErrorBatch(batch)
  }

  async processErrorBatch(errors) {
    if (errors.length === 0) return

    this.isProcessing = true

    try {
      // Send to error tracking service
      await this.sendErrorBatch(errors)
      
      // Send to monitoring systems
      this.sendToMonitoring(errors)
      
      // Store locally as backup
      this.storeErrorsLocally(errors)
      
    } catch (error) {
      console.error('Failed to process error batch:', error)
      
      // Re-queue errors on failure
      this.errorQueue.unshift(...errors)
    } finally {
      this.isProcessing = false
    }
  }

  async sendErrorBatch(errors) {
    const response = await fetch('/api/errors/batch', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        errors,
        batchId: this.generateBatchId(),
        timestamp: Date.now()
      })
    })

    if (!response.ok) {
      throw new Error(`Error reporting failed: ${response.status}`)
    }
  }

  sendToMonitoring(errors) {
    errors.forEach(error => {
      // Send to performance monitoring
      if (window.performanceMonitor) {
        window.performanceMonitor.sendMetric('global_error', {
          type: error.type,
          message: error.message,
          timestamp: error.timestamp
        })
      }

      // Send to Sentry
      if (window.Sentry) {
        window.Sentry.captureException(new Error(error.message), {
          tags: {
            errorType: error.type,
            source: 'global_handler'
          },
          extra: error
        })
      }
    })
  }

  storeErrorsLocally(errors) {
    try {
      const existing = JSON.parse(localStorage.getItem('global_errors') || '[]')
      const combined = [...existing, ...errors]
      
      // Keep only last 100 errors
      const trimmed = combined.slice(-100)
      
      localStorage.setItem('global_errors', JSON.stringify(trimmed))
    } catch (error) {
      console.warn('Failed to store errors locally:', error)
    }
  }

  isCriticalError(error) {
    const criticalTypes = ['javascript_error']
    const criticalPatterns = [
      /ChunkLoadError/,
      /Network Error/,
      /Failed to fetch/,
      /Script error/
    ]

    return criticalTypes.includes(error.type) || 
           criticalPatterns.some(pattern => pattern.test(error.message))
  }

  generateBatchId() {
    return `batch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  getSessionId() {
    let sessionId = sessionStorage.getItem('sessionId')
    if (!sessionId) {
      sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      sessionStorage.setItem('sessionId', sessionId)
    }
    return sessionId
  }

  getUserId() {
    return localStorage.getItem('userId') || 'anonymous'
  }

  getErrorStats() {
    return {
      queueLength: this.errorQueue.length,
      isProcessing: this.isProcessing,
      totalErrorsStored: JSON.parse(localStorage.getItem('global_errors') || '[]').length
    }
  }
}

export const globalErrorHandler = new GlobalErrorHandler()
```
:::

## User Analytics and Behavior Monitoring

Track user interactions, feature usage, and application performance from the user perspective.

### Comprehensive User Analytics

Implement detailed user behavior tracking:

::: example
**Advanced User Analytics System**

```javascript
// src/monitoring/userAnalytics.js
class UserAnalytics {
  constructor() {
    this.events = []
    this.session = this.initializeSession()
    this.user = this.initializeUser()
    this.pageViews = new Map()
    this.interactions = []
    this.isRecording = true
  }

  initializeSession() {
    let sessionId = sessionStorage.getItem('analytics_session')
    let sessionStart = sessionStorage.getItem('session_start')
    
    if (!sessionId) {
      sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      sessionStart = Date.now()
      sessionStorage.setItem('analytics_session', sessionId)
      sessionStorage.setItem('session_start', sessionStart)
    }

    return {
      id: sessionId,
      startTime: parseInt(sessionStart),
      lastActivity: Date.now()
    }
  }

  initializeUser() {
    let userId = localStorage.getItem('analytics_user')
    
    if (!userId) {
      userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      localStorage.setItem('analytics_user', userId)
    }

    return {
      id: userId,
      isAuthenticated: this.checkAuthenticationStatus(),
      firstVisit: localStorage.getItem('first_visit') || Date.now()
    }
  }

  checkAuthenticationStatus() {
    // Check if user is authenticated
    return !!(localStorage.getItem('authToken') || sessionStorage.getItem('authToken'))
  }

  trackPageView(path, title) {
    const pageView = {
      type: 'page_view',
      path,
      title,
      timestamp: Date.now(),
      referrer: document.referrer,
      sessionId: this.session.id,
      userId: this.user.id
    }

    this.recordEvent(pageView)
    this.updatePageViewMetrics(path)
  }

  trackEvent(eventName, properties = {}) {
    const event = {
      type: 'custom_event',
      name: eventName,
      properties,
      timestamp: Date.now(),
      sessionId: this.session.id,
      userId: this.user.id,
      url: window.location.href
    }

    this.recordEvent(event)
  }

  trackUserInteraction(element, action, additionalData = {}) {
    const interaction = {
      type: 'user_interaction',
      element: this.getElementInfo(element),
      action,
      timestamp: Date.now(),
      sessionId: this.session.id,
      userId: this.user.id,
      ...additionalData
    }

    this.recordEvent(interaction)
    this.interactions.push(interaction)
  }

  trackPerformanceMetric(metricName, value, context = {}) {
    const metric = {
      type: 'performance_metric',
      name: metricName,
      value,
      context,
      timestamp: Date.now(),
      sessionId: this.session.id,
      userId: this.user.id,
      url: window.location.href
    }

    this.recordEvent(metric)
  }

  trackConversion(conversionType, value = null, metadata = {}) {
    const conversion = {
      type: 'conversion',
      conversionType,
      value,
      metadata,
      timestamp: Date.now(),
      sessionId: this.session.id,
      userId: this.user.id,
      url: window.location.href
    }

    this.recordEvent(conversion)
    this.sendImmediateEvent(conversion) // Send conversions immediately
  }

  trackError(error, context = {}) {
    const errorEvent = {
      type: 'error_event',
      message: error.message,
      stack: error.stack,
      context,
      timestamp: Date.now(),
      sessionId: this.session.id,
      userId: this.user.id,
      url: window.location.href
    }

    this.recordEvent(errorEvent)
  }

  getElementInfo(element) {
    if (!element) return null

    return {
      tagName: element.tagName,
      id: element.id,
      className: element.className,
      textContent: element.textContent?.substring(0, 100),
      attributes: this.getRelevantAttributes(element)
    }
  }

  getRelevantAttributes(element) {
    const relevantAttrs = ['data-testid', 'data-track', 'aria-label', 'title']
    const attrs = {}

    relevantAttrs.forEach(attr => {
      if (element.hasAttribute(attr)) {
        attrs[attr] = element.getAttribute(attr)
      }
    })

    return attrs
  }

  recordEvent(event) {
    if (!this.isRecording) return

    // Add common metadata
    event.userAgent = navigator.userAgent
    event.viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    }
    event.buildVersion = process.env.REACT_APP_VERSION
    event.environment = process.env.NODE_ENV

    this.events.push(event)
    this.updateSessionActivity()

    // Batch send events
    if (this.events.length >= 10) {
      this.sendEventBatch()
    }
  }

  updateSessionActivity() {
    this.session.lastActivity = Date.now()
    sessionStorage.setItem('last_activity', this.session.lastActivity.toString())
  }

  updatePageViewMetrics(path) {
    const views = this.pageViews.get(path) || { count: 0, firstView: Date.now() }
    views.count++
    views.lastView = Date.now()
    this.pageViews.set(path, views)
  }

  async sendEventBatch() {
    if (this.events.length === 0) return

    const batch = [...this.events]
    this.events = []

    try {
      await this.sendAnalytics(batch)
    } catch (error) {
      console.warn('Analytics batch send failed:', error)
      // Re-queue events on failure
      this.events.unshift(...batch)
    }
  }

  async sendImmediateEvent(event) {
    try {
      await this.sendAnalytics([event])
    } catch (error) {
      console.warn('Immediate event send failed:', error)
      this.events.push(event) // Add to batch queue as fallback
    }
  }

  async sendAnalytics(events) {
    const payload = {
      events,
      session: this.session,
      user: this.user,
      timestamp: Date.now()
    }

    const response = await fetch('/api/analytics', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    })

    if (!response.ok) {
      throw new Error(`Analytics API error: ${response.status}`)
    }
  }

  startSessionTracking() {
    // Track session duration
    setInterval(() => {
      this.trackSessionHeartbeat()
    }, 30000) // Every 30 seconds

    // Track page visibility changes
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        this.trackEvent('page_hidden')
      } else {
        this.trackEvent('page_visible')
      }
    })

    // Track window focus/blur
    window.addEventListener('focus', () => this.trackEvent('window_focus'))
    window.addEventListener('blur', () => this.trackEvent('window_blur'))

    // Track beforeunload for session end
    window.addEventListener('beforeunload', () => {
      this.trackSessionEnd()
    })
  }

  trackSessionHeartbeat() {
    const sessionDuration = Date.now() - this.session.startTime
    this.trackEvent('session_heartbeat', {
      sessionDuration,
      pageViewCount: this.pageViews.size,
      interactionCount: this.interactions.length
    })
  }

  trackSessionEnd() {
    const sessionDuration = Date.now() - this.session.startTime
    const endEvent = {
      type: 'session_end',
      duration: sessionDuration,
      pageViews: Array.from(this.pageViews.entries()),
      interactionCount: this.interactions.length,
      timestamp: Date.now(),
      sessionId: this.session.id,
      userId: this.user.id
    }

    // Send immediately using beacon API for reliable delivery
    navigator.sendBeacon('/api/analytics/session-end', JSON.stringify(endEvent))
  }

  getAnalyticsData() {
    return {
      session: this.session,
      user: this.user,
      events: this.events,
      pageViews: Array.from(this.pageViews.entries()),
      interactions: this.interactions
    }
  }

  pauseRecording() {
    this.isRecording = false
  }

  resumeRecording() {
    this.isRecording = true
  }

  clearData() {
    this.events = []
    this.interactions = []
    this.pageViews.clear()
  }
}

export const userAnalytics = new UserAnalytics()

// React hook for easy analytics integration
export function useAnalytics() {
  const trackEvent = useCallback((eventName, properties) => {
    userAnalytics.trackEvent(eventName, properties)
  }, [])

  const trackPageView = useCallback((path, title) => {
    userAnalytics.trackPageView(path, title)
  }, [])

  const trackConversion = useCallback((type, value, metadata) => {
    userAnalytics.trackConversion(type, value, metadata)
  }, [])

  return {
    trackEvent,
    trackPageView,
    trackConversion
  }
}

// HOC for automatic interaction tracking
export function withAnalytics(WrappedComponent, componentName) {
  const AnalyticsComponent = (props) => {
    const ref = useRef(null)

    useEffect(() => {
      const element = ref.current
      if (!element) return

      const handleClick = (event) => {
        userAnalytics.trackUserInteraction(event.target, 'click', {
          component: componentName
        })
      }

      element.addEventListener('click', handleClick)
      return () => element.removeEventListener('click', handleClick)
    }, [])

    return (
      <div ref={ref}>
        <WrappedComponent {...props} />
      </div>
    )
  }

  AnalyticsComponent.displayName = `withAnalytics(${componentName})`
  return AnalyticsComponent
}
```
:::

::: tip
**Monitoring Data Privacy**

Implement analytics and monitoring with privacy considerations:
- Anonymize personally identifiable information (PII)
- Provide opt-out mechanisms for user tracking
- Comply with GDPR, CCPA, and other privacy regulations
- Implement data retention policies and automatic cleanup
- Use client-side aggregation to minimize data transmission
:::

::: note
**Performance Impact Management**

Minimize monitoring overhead through:
- Asynchronous data collection and transmission
- Intelligent sampling for high-traffic applications
- Efficient event batching and compression
- Resource monitoring to prevent performance degradation
- Graceful degradation when monitoring services are unavailable
:::

Comprehensive monitoring and observability provide the foundation for reliable React application operations and continuous improvement. The systems covered in this section enable teams to maintain application quality, optimize performance, and respond effectively to issues while supporting data-driven decision making and operational excellence.
