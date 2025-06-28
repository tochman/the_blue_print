# Monitoring and observability: understanding your application's real-world performance

Picture this scenario: Your React application passes all tests, deploys successfully, and shows green status indicators. Yet users are abandoning shopping carts, reporting slow loading times, and encountering errors you've never seen. The gap between "working in development" and "working for users" is what monitoring and observability help you bridge.

This chapter transforms how you think about application health: from basic uptime checks to understanding the complete user experience. You'll learn to build monitoring systems that tell meaningful stories about your application's performance and help you make data-driven improvements.

## The hidden reality of production applications

### When "Working" Isn't Really Working {.unnumbered .unlisted}

Here's a real-world wake-up call: A successful startup celebrated their React e-commerce platform's 99.9% uptime and perfect test suite. Everything appeared healthy until they implemented comprehensive user monitoring.

**The shocking discoveries:**

- 15% of users experienced load times exceeding 10 seconds
- Mobile users had 40% higher abandonment rates due to performance issues
- JavaScript errors affected 8% of sessions but went completely undetected
- Critical user flows failed silently for users with slower internet connections
- Geographic performance varied dramatically, with some regions experiencing 5x slower loading

The application was technically "up" but functionally broken for many users. This gap between technical metrics and user experience is why monitoring matters.

### From Server-Centric to User-Centric Thinking {.unnumbered .unlisted}

Traditional monitoring focuses on infrastructure: "Is the server running?" Modern observability asks better questions: "Are users successful?" This shift changes everything about how you approach application health.

**Traditional monitoring mindset:**

- Server uptime and response codes
- Database connection status
- Memory and CPU usage
- Basic error logs

**User-centric observability mindset:**

- Real user loading experiences
- Error impact on user workflows
- Performance across different devices and networks
- Business metrics tied to technical performance

::: important
**The Monitoring Philosophy**

Effective monitoring tells stories about user success, not just system status. Your goal is understanding how technical performance affects user experience and business outcomes. Monitor what helps you make users more successful, not just what's easy to measure.

**Core principle**: Observe user journeys, not just system metrics.
:::

## Building Your Monitoring Strategy: A Decision Framework 

Before diving into tools and implementation, you need a clear strategy that matches your application's needs and your team's capacity.

### The Monitoring Maturity Pyramid {.unnumbered .unlisted}

Think of monitoring capabilities as a pyramid: build strong foundations before adding complexity:

**Foundation Layer: Essential Visibility**
- Error detection and alerting
- Basic performance metrics
- User flow completion rates
- Critical functionality monitoring

**Enhancement Layer: User Experience**
- Real user monitoring (RUM)
- Performance across different conditions
- User behavior patterns
- Mobile and cross-browser insights

**Advanced Layer: Business Intelligence**
- Predictive issue detection
- Business impact correlation
- Advanced analytics and segmentation
- Custom metrics for your specific domain

**Why this progression works:**
 Each layer provides value independently while enabling the next level. You can stop at any layer and still have meaningful monitoring, but each addition compounds the value of previous investments.

### Choosing Your Monitoring Approach {.unnumbered .unlisted}

Different applications need different monitoring strategies. Here's how to decide what's right for your situation:

**For Portfolio and Learning Projects:**

*Focus: Learning and basic error detection*
- **Priority metrics**: Error rates, basic performance, user flows
- **Tools to explore**: Browser DevTools, simple error tracking, built-in platform monitoring
- **Time investment**: 2-4 hours initial setup, minimal ongoing maintenance
- **Key benefit**: Learning monitoring concepts without overwhelming complexity

**For Business Applications:**

*Focus: User experience and business impact*
- **Priority metrics**: User-centric performance, conversion funnels, error impact
- **Tools to explore**: Comprehensive monitoring platforms, custom dashboards, user analytics
- **Time investment**: 1-2 days initial setup, weekly review and optimization
- **Key benefit**: Data-driven decision making and proactive issue resolution

**For Enterprise Applications:**

*Focus: Comprehensive observability and compliance*
- **Priority metrics**: Detailed diagnostics, compliance tracking, predictive insights
- **Tools to explore**: Enterprise platforms, custom instrumentation, advanced analytics
- **Time investment**: Weeks for proper setup, dedicated monitoring operations
- **Key benefit**: Enterprise-grade reliability and detailed operational insights

::: note
**Tool Examples: Guidance, Not Gospel**

Throughout this chapter, we'll reference tools like Google Analytics, Sentry, New Relic, Datadog, and others. These are examples to illustrate monitoring concepts and capabilities, not specific recommendations or endorsements.

The monitoring tool landscape evolves rapidly. What matters most is understanding what each type of monitoring accomplishes, so you can evaluate current options and choose what fits your specific needs, budget, and team expertise. Many tools offer free tiers that let you start small and grow your monitoring sophistication over time.
:::

### Building Your Monitoring Decision Tree {.unnumbered .unlisted}

Use this framework to determine what monitoring capabilities to implement first:

**Step 1: Identify Your Biggest Risk**
- New application: Focus on error detection and basic performance
- Growing user base: Prioritize user experience monitoring
- Business-critical application: Emphasize availability and business impact tracking
- Complex application: Start with error tracking, then add performance monitoring

**Step 2: Consider Your Resources**
- Small team: Start with managed solutions and automated monitoring
- Technical team: Consider custom instrumentation and detailed metrics
- Limited budget: Utilize free tiers and open-source tools
- Growing budget: Invest in comprehensive platforms as value becomes clear

**Step 3: Define Success Metrics**
- User satisfaction: Focus on performance and error reduction
- Business growth: Track conversion and engagement metrics
- Operational efficiency: Monitor system health and team productivity
- Compliance requirements: Implement audit trails and security monitoring

## Essential Monitoring Categories: What Really Matters

Let's explore the key types of monitoring every React application should consider, starting with the most critical and building complexity gradually.

### 1. Error Detection and Tracking {.unnumbered .unlisted}

**Why it's critical:**
 If users encounter errors and you don't know about them, you can't fix them. Error tracking is your safety net for maintaining application quality.

**What to monitor:**

- JavaScript runtime errors and exceptions
- React component crashes and boundary triggers
- Network request failures and API errors
- User action failures (form submissions, clicks that don't work)

**Key insights you'll gain:**

- Which errors affect the most users
- Error frequency and trends over time
- User context when errors occur
- Browser and device patterns in error rates

**Progressive implementation approach:**

1. **Start simple**: Implement basic browser error capturing
2. **Add context**: Include user actions and application state
3. **Enhance reporting**: Add error categorization and impact metrics
4. **Optimize response**: Create automated alerts and resolution workflows

### 2. Performance Monitoring {.unnumbered .unlisted}

**Why it matters:**
 Performance directly affects user experience, conversion rates, and business success. Slow applications lose users, regardless of functionality.

**Core Web Vitals to track:**

- **Largest Contentful Paint (LCP)**: How quickly main content loads
- **First Input Delay (FID)**: How quickly the app responds to user interaction
- **Cumulative Layout Shift (CLS)**: How much content moves around while loading

**Real User Monitoring (RUM) insights:**

- Performance across different devices and network conditions
- Geographic performance variations
- Time-based performance patterns
- User journey performance bottlenecks

**Progressive implementation approach:**

1. **Foundation**: Track basic loading times and Core Web Vitals
2. **Enhancement**: Add real user monitoring across different conditions
3. **Optimization**: Implement performance budgets and regression detection
4. **Advanced**: Create custom performance metrics for your specific application

### 3. User Experience and Behavior Monitoring {.unnumbered .unlisted}

**Why it's valuable:**
 Understanding how users actually interact with your application helps you identify improvement opportunities and validate design decisions.

**Key user experience metrics:**

- User flow completion rates
- Feature adoption and usage patterns
- Session duration and engagement
- Mobile vs. desktop experience differences

**Business impact monitoring:**

- Conversion funnel performance
- Feature usage correlation with user success
- Technical performance impact on business metrics
- User satisfaction and retention patterns

### 4. Application Health and Availability {.unnumbered .unlisted}

**Why it's fundamental:**
 While user-centric metrics are crucial, you still need to ensure your application's basic infrastructure is healthy.

**Essential health metrics:**

- Application availability and uptime
- API response times and error rates
- Database performance and connectivity
- Third-party service dependencies

## Implementing Monitoring: A Practical Approach

### Starting with Error Tracking {.unnumbered .unlisted}

The most important monitoring you can implement is error detection. Here's a practical approach to get meaningful error insights quickly:

**Essential error tracking setup:**

```javascript
// Basic error boundary for React components
class ErrorBoundary extends React.Component {
  componentDidCatch(error, errorInfo) {
    // Log error with context for monitoring
    console.error('Component error:', {
      error: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
      timestamp: new Date().toISOString(),
      url: window.location.href
    })
    
    // Send to monitoring service in production
    if (process.env.NODE_ENV === 'production') {
      // Replace with your chosen monitoring service
      monitoringService.reportError(error, errorInfo)
    }
  }
  
  render() {
    if (this.state.hasError) {
      return <div>Something went wrong. Please try refreshing the page.</div>
    }
    return this.props.children
  }
}
```

**Why this approach works:**

- Catches React component errors automatically
- Provides contextual information for debugging
- Gives users a graceful error experience
- Integrates easily with external monitoring services

### Progressive Performance Monitoring {.unnumbered .unlisted}

Start with browser-native performance APIs, then enhance based on your needs:

**Basic performance tracking:**

```javascript
// Simple performance monitoring
window.addEventListener('load', () => {
  // Get navigation timing
  const navigationTiming = performance.getEntriesByType('navigation')[0]
  
  // Track key metrics
  const metrics = {
    pageLoadTime: navigationTiming.loadEventEnd - navigationTiming.fetchStart,
    domContentLoaded: navigationTiming.domContentLoadedEventEnd - navigationTiming.fetchStart,
    firstPaint: performance.getEntriesByType('paint')[0]?.startTime,
    timestamp: new Date().toISOString()
  }
  
  // Log for development, send to service in production
  console.log('Performance metrics:', metrics)
})
```

**What this gives you:**

- Basic loading performance insights
- Foundation for more advanced monitoring
- Easy integration with monitoring services
- Immediate feedback on performance changes

## Troubleshooting Common Monitoring Challenges

### Challenge: Alert Fatigue and Noise {.unnumbered .unlisted}

**Problem**: Too many alerts make it hard to identify real issues.

**Solutions:**

- Set alert thresholds based on user impact, not arbitrary numbers
- Group related alerts to reduce notification volume
- Implement alert escalation (warn, then alert, then urgent)
- Review and adjust alert sensitivity regularly based on actual incidents

**Practical approach**: Start with fewer, high-impact alerts. Add more specific monitoring as you understand your application's normal behavior patterns.

### Challenge: Performance Monitoring Overhead {.unnumbered .unlisted}

**Problem**: Monitoring itself impacts application performance.

**Solutions:**

- Use sampling for high-traffic applications (monitor 1% of requests for trends)
- Implement asynchronous data collection and transmission
- Batch monitoring data to reduce network requests
- Monitor the performance impact of your monitoring code

**Balance strategy**: The insights from monitoring should significantly outweigh the performance cost. If monitoring noticeably slows your application, you're over-monitoring.

### Challenge: Data Privacy and Compliance {.unnumbered .unlisted}

**Problem**: Monitoring can inadvertently collect sensitive user information.

**Solutions:**

- Implement data anonymization and scrubbing
- Provide clear user opt-out mechanisms
- Follow GDPR, CCPA, and other relevant privacy regulations
- Regular audit of collected data and retention policies

**Best practice**: Design monitoring with privacy-by-default principles. Collect the minimum data needed for actionable insights.

### Challenge: Making Monitoring Data Actionable {.unnumbered .unlisted}

**Problem**: Having lots of monitoring data but struggling to use it effectively.

**Solutions:**

- Define clear action items for each metric you track
- Create monitoring dashboards focused on decision-making
- Establish regular review processes for monitoring data
- Connect technical metrics to business outcomes

**Key mindset**: Every piece of monitoring data should either help you make a decision or improve user experience. If it doesn't, consider whether you need to collect it.

## Choosing and Implementing Monitoring Tools

### Evaluation Framework for Monitoring Tools {.unnumbered .unlisted}

When selecting monitoring solutions, consider these factors:

**Technical Requirements:**

- Integration ease with React applications
- Support for your deployment platforms
- API capabilities for custom integrations
- Performance impact on your application

**Business Requirements:**

- Pricing model and cost scalability
- Team collaboration features
- Alerting and notification capabilities
- Compliance and security features

**Growth Considerations:**

- Free tier availability for getting started
- Scaling capabilities as your application grows
- Customization options for advanced needs
- Migration path if you outgrow the tool

### Popular Monitoring Tool Categories {.unnumbered .unlisted}

**All-in-One Application Performance Monitoring (APM):**

- Examples: New Relic, Datadog, Dynatrace
- Best for: Teams wanting comprehensive monitoring in one platform
- Strengths: Integrated insights, minimal setup complexity
- Considerations: Higher cost, less customization flexibility

**Specialized Error Tracking:**

- Examples: Sentry, Bugsnag, Rollbar
- Best for: Teams prioritizing error detection and resolution
- Strengths: Excellent error context, developer-friendly workflows
- Considerations: May need additional tools for performance monitoring

**User Analytics and RUM:**

- Examples: Google Analytics, Mixpanel, LogRocket
- Best for: Teams focusing on user behavior and experience
- Strengths: User journey insights, business metric correlation
- Considerations: May require technical monitoring additions

**Custom and Open Source:**

- Examples: Prometheus + Grafana, ELK Stack, custom solutions
- Best for: Teams with specific requirements or budget constraints
- Strengths: Maximum customization, cost control
- Considerations: Higher setup complexity, ongoing maintenance

### Implementation Best Practices {.unnumbered .unlisted}

**Start Small and Grow:**

1. Begin with basic error tracking and performance monitoring
2. Add user experience monitoring as you understand your baseline
3. Implement business metric tracking once technical monitoring is stable
4. Consider advanced features only after mastering the basics

**Integration Strategy:**

- Use monitoring libraries that integrate well with React
- Implement monitoring consistently across your application
- Create reusable monitoring components and hooks
- Document your monitoring setup for team knowledge sharing

**Data Management:**

- Establish data retention policies before collecting large amounts of data
- Implement sampling strategies for high-volume applications
- Create backup plans for monitoring service outages
- Regular review and cleanup of unused monitoring configurations

## Summary: Building Effective Application Observability

Monitoring and observability transform your React application from a black box into a transparent, continuously improving system. The key to success is starting with clear goals, implementing monitoring progressively, and always connecting technical metrics to user experience and business outcomes.

**Essential monitoring principles:**

- **User-centric focus**: Monitor what affects user success, not just technical metrics
- **Progressive implementation**: Start simple and add complexity as you understand your application's behavior
- **Actionable insights**: Every metric should inform decisions or improvements
- **Privacy-conscious design**: Collect only the data you need while respecting user privacy

**Your monitoring journey:**

1. **Foundation**: Error tracking and basic performance monitoring
2. **Enhancement**: Real user monitoring and user experience metrics
3. **Optimization**: Business impact correlation and predictive insights
4. **Mastery**: Custom metrics and advanced analytics for your specific domain

**Key decision framework:**

- What user experience problems are you trying to solve?
- What business decisions will this monitoring data inform?
- How will you respond when monitoring identifies issues?
- What's the minimum viable monitoring that provides maximum insight?

Remember that monitoring tools and technologies will continue to evolve, but the fundamental principles of user-centric observability remain constant. Focus on understanding these principles, and you'll be able to adapt to new tools and approaches as they emerge.

The investment you make in proper monitoring pays dividends in application reliability, user satisfaction, and team confidence. Start with the basics, iterate based on what you learn, and build monitoring systems that help your React applications truly succeed in the real world.

## Understanding What Matters: A Monitoring Strategy

Before implementing monitoring tools, you need to understand what actually matters for your specific application and users.

### The User Experience Monitoring Pyramid {.unnumbered .unlisted}

Just like testing, monitoring should follow a pyramid structure: more basic checks at the bottom, fewer complex checks at the top:

**Foundation Layer - Core Functionality:**

- Application availability (can users access your app?)
- Critical user flows (can users complete key tasks?)
- Error rates (how often do things break?)

**Performance Layer - User Experience:**

- Loading times (how fast does your app feel?)
- Interaction responsiveness (do buttons respond quickly?)
- Mobile performance (does it work well on phones?)

**Business Layer - Impact Metrics:**

- Conversion rates (are users achieving their goals?)
- User satisfaction (are users happy with the experience?)
- Feature adoption (which features get used?)

::: note
**Why This Structure Works**

Basic functionality monitoring catches the big problems quickly and cheaply. Performance monitoring helps you understand user experience. Business monitoring connects technical metrics to actual impact. This layered approach prevents alert fatigue while ensuring important issues get attention.
:::

### Building Your Monitoring Decision Framework {.unnumbered .unlisted}

Not every application needs the same monitoring approach. Here's how to decide what matters for your situation:

**For personal projects and portfolios:**

- Focus on: Basic uptime, error tracking, performance insights
- Tools to consider: Browser dev tools, simple error tracking, built-in platform monitoring
- Time investment: 1-2 hours setup, minimal ongoing maintenance

**For business applications:**

- Focus on: User experience, business impact metrics, proactive alerting
- Tools to consider: Comprehensive APM, user analytics, custom dashboards
- Time investment: 1-2 days setup, regular review and optimization

**For enterprise applications:**

- Focus on: Compliance, detailed diagnostics, predictive monitoring
- Tools to consider: Enterprise monitoring platforms, custom instrumentation, advanced analytics
- Time investment: Weeks to set up properly, dedicated monitoring team

::: note
**Tool Selection: Examples, Not Endorsements**

Throughout this chapter, we'll mention specific tools like Google Analytics, Sentry, New Relic, and others. These are examples to illustrate monitoring concepts, not endorsements. The monitoring landscape changes rapidly, and the best choice depends on your specific needs, budget, and team expertise.

Many monitoring tools offer free tiers that let you start small and grow. The key is understanding what each type of monitoring accomplishes so you can choose the right approach for your needs.
:::

## Getting Started: Essential Monitoring for React Applications

Let's implement basic but effective monitoring step by step, starting with the most important insights and building from there.

### Step 1: Error Tracking - Know When Things Break {.unnumbered .unlisted}

Error tracking is the most important monitoring you can implement. If users encounter errors and you don't know about them, you can't fix them.

::: example
**Simple Error Tracking Setup**

```javascript
// src/utils/errorTracking.js
class SimpleErrorTracker {
  constructor() {
    this.errors = []
    this.setupGlobalErrorHandling()
  }

  setupGlobalErrorHandling() {
    // Catch JavaScript errors
    window.addEventListener('error', (event) => {
      this.trackError({
        type: 'javascript',
        message: event.message,
        filename: event.filename,
        line: event.lineno,
        column: event.colno,
        stack: event.error?.stack,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        url: window.location.href
      })
    })

    // Catch unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.trackError({
        type: 'promise_rejection',
        message: event.reason?.message || 'Unhandled promise rejection',
        stack: event.reason?.stack,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        url: window.location.href
      })
    })
  }

  // Manual error tracking for React components
  trackError(errorInfo) {
    // Store locally for development
    this.errors.push(errorInfo)
    
    // Log to console for immediate visibility
    console.error('Error tracked:', errorInfo)
    
    // Send to monitoring service in production
    if (process.env.NODE_ENV === 'production') {
      this.sendToMonitoringService(errorInfo)
    }
  }

  async sendToMonitoringService(errorInfo) {
    try {
      // Replace with your actual monitoring service
      await fetch('/api/errors', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(errorInfo)
      })
    } catch (error) {
      console.warn('Failed to send error to monitoring service:', error)
    }
  }

  // Get error summary for debugging
  getErrorSummary() {
    return {
      totalErrors: this.errors.length,
      recentErrors: this.errors.slice(-10),
      errorTypes: this.errors.reduce((types, error) => {
        types[error.type] = (types[error.type] || 0) + 1
        return types
      }, {})
    }
  }
}

// Initialize error tracking
const errorTracker = new SimpleErrorTracker()

export default errorTracker
```

```jsx
// src/components/ErrorBoundary.jsx - Catch React component errors
import React from 'react'
import errorTracker from '../utils/errorTracking'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  componentDidCatch(error, errorInfo) {
    // Track the error with context
    errorTracker.trackError({
      type: 'react_component',
      message: error.message,
      stack: error.stack,
      componentStack: errorInfo.componentStack,
      timestamp: new Date().toISOString(),
      props: this.props.errorContext || {},
      url: window.location.href
    })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <p>We've been notified about this issue and will fix it soon.</p>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
```

**Key benefits of this approach:**

- Catches errors automatically without requiring changes to existing code
- Provides context about where and when errors occur
- Graceful degradation when errors happen
- Easy to extend with additional monitoring services
:::

### Step 2: Performance Monitoring - Understand User Experience {.unnumbered .unlisted}

Performance monitoring helps you understand how your application actually feels to users, not just how fast it loads in ideal conditions.

### Real User Monitoring (RUM) {.unnumbered .unlisted}

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

### Component Performance Tracking {.unnumbered .unlisted}

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

### Advanced Error Boundary Implementation {.unnumbered .unlisted}

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

### Unhandled Error Monitoring {.unnumbered .unlisted}

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

### Comprehensive User Analytics {.unnumbered .unlisted}

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
