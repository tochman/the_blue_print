# Provider Patterns and Architectural Composition

Provider patterns extend far beyond simple prop drilling solutions. When implemented with architectural sophistication, providers become the foundational infrastructure of scalable applications—they replace complex state management libraries, coordinate service dependencies, and establish clean architectural boundaries that enhance code maintainability and development experience.

The provider pattern's architectural strength emerges through its ability to create clear boundaries while preserving flexibility and testability. Advanced provider patterns manage complex application state, coordinate multiple service dependencies, and provide elegant solutions for cross-cutting concerns including authentication, theming, and API management.

::: important
**Providers as Architectural Infrastructure**

Well-designed provider patterns form the foundational infrastructure of scalable React applications. They provide dependency injection, state management, and service coordination while maintaining clear separation of concerns. Advanced provider architectures can eliminate the need for external state management libraries in many application scenarios.
:::

## Hierarchical Provider Composition Strategies

Complex applications benefit from hierarchical provider structures that enable granular control over dependencies and state scope. This architectural pattern allows different application sections to access distinct sets of services and state management capabilities.

::: example
```jsx
// Base provider system with dependency resolution
function createProviderHierarchy() {
  const providers = new Map();
  
  const registerProvider = (name, Provider, dependencies = []) => {
    providers.set(name, { Provider, dependencies });
  };

  const buildProviderTree = (requestedProviders, children) => {
    // Resolve dependencies and build provider tree
    const sorted = topologicalSort(requestedProviders, providers);
    
    return sorted.reduceRight((acc, providerName) => {
      const { Provider } = providers.get(providerName);
      return <Provider key={providerName}>{acc}</Provider>;
    }, children);
  };

  return { registerProvider, buildProviderTree };
}

// Application-specific provider configuration
const AppProviderRegistry = createProviderHierarchy();

function ConfigProvider({ children }) {
  const config = {
    apiBaseURL: process.env.REACT_APP_API_URL,
    analyticsTrackingId: process.env.REACT_APP_ANALYTICS_ID,
    features: {
      advancedAnalytics: process.env.REACT_APP_ADVANCED_ANALYTICS === 'true',
      socialSharing: process.env.REACT_APP_SOCIAL_SHARING === 'true'
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
  const api = useMemo(() => new PracticeAPIService(config.apiBaseURL), [config]);

  return (
    <ApiContext.Provider value={api}>
      {children}
    </ApiContext.Provider>
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
    <AppProviders providers={['config', 'api', 'auth', 'practiceSession']}>
      <Dashboard />
    </AppProviders>
  );
}

function AppProviders({ providers, children }) {
  return AppProviderRegistry.buildProviderTree(providers, children);
}
```
:::

## Service Container Patterns

Service containers provide sophisticated dependency injection with lazy loading, service decoration, and complex service resolution patterns.

::: example
```jsx
// Advanced service container implementation
class ServiceContainer {
  constructor() {
    this.services = new Map();
    this.singletons = new Map();
    this.factories = new Map();
    this.decorators = new Map();
  }

  register(name, factory, options = {}) {
    const { singleton = false, dependencies = [] } = options;
    
    this.factories.set(name, {
      factory,
      dependencies,
      singleton
    });
  }

  resolve(name) {
    // Check if singleton instance exists
    if (this.singletons.has(name)) {
      return this.singletons.get(name);
    }

    const serviceConfig = this.factories.get(name);
    if (!serviceConfig) {
      throw new Error(`Service '${name}' not registered`);
    }

    // Resolve dependencies
    const dependencies = serviceConfig.dependencies.reduce((deps, depName) => {
      deps[depName] = this.resolve(depName);
      return deps;
    }, {});

    // Create service instance
    let instance = serviceConfig.factory(dependencies);

    // Apply decorators
    const decorators = this.decorators.get(name) || [];
    instance = decorators.reduce((service, decorator) => decorator(service), instance);

    // Store singleton if needed
    if (serviceConfig.singleton) {
      this.singletons.set(name, instance);
    }

    return instance;
  }

  decorate(serviceName, decorator) {
    if (!this.decorators.has(serviceName)) {
      this.decorators.set(serviceName, []);
    }
    this.decorators.get(serviceName).push(decorator);
  }

  clear() {
    this.services.clear();
    this.singletons.clear();
  }
}

// Service container provider
function ServiceContainerProvider({ children }) {
  const container = useMemo(() => {
    const serviceContainer = new ServiceContainer();

    // Register core services
    serviceContainer.register('config', () => ({
      apiBaseURL: process.env.REACT_APP_API_URL,
      enableAnalytics: process.env.REACT_APP_ANALYTICS === 'true'
    }), { singleton: true });

    serviceContainer.register('httpClient', ({ config }) => {
      return new HttpClient(config.apiBaseURL);
    }, { dependencies: ['config'], singleton: true });

    serviceContainer.register('practiceAPI', ({ httpClient }) => {
      return new PracticeAPIService(httpClient);
    }, { dependencies: ['httpClient'], singleton: true });

    serviceContainer.register('analytics', ({ config }) => {
      return config.enableAnalytics ? new AnalyticsService() : new NoOpAnalyticsService();
    }, { dependencies: ['config'], singleton: true });

    // Add logging decorator to all services
    serviceContainer.decorate('practiceAPI', (service) => {
      return new Proxy(service, {
        get(target, prop) {
          if (typeof target[prop] === 'function') {
            return function(...args) {
              console.log(`Calling ${prop} with args:`, args);
              return target[prop].apply(target, args);
            };
          }
          return target[prop];
        }
      });
    });

    return serviceContainer;
  }, []);

  return (
    <ServiceContainerContext.Provider value={container}>
      {children}
    </ServiceContainerContext.Provider>
  );
}

function useService(serviceName) {
  const container = useContext(ServiceContainerContext);
  return useMemo(() => container.resolve(serviceName), [container, serviceName]);
}
```
:::

## Performance Optimization Strategies

Provider architectures require careful performance optimization to prevent unnecessary re-renders and maintain smooth user experiences.

::: example
```jsx
// Split context patterns for performance
const UserDataContext = createContext();
const UserActionsContext = createContext();

function OptimizedUserProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [preferences, setPreferences] = useState({});

  // Memoize actions to prevent unnecessary re-renders
  const actions = useMemo(() => ({
    login: async (credentials) => {
      const user = await api.login(credentials);
      setUser(user);
      return user;
    },
    logout: async () => {
      await api.logout();
      setUser(null);
      setPreferences({});
    },
    updateUser: (updates) => {
      setUser(prev => ({ ...prev, ...updates }));
    },
    updatePreferences: (newPreferences) => {
      setPreferences(prev => ({ ...prev, ...newPreferences }));
    }
  }), []);

  // Memoize stable data to prevent unnecessary re-renders
  const userData = useMemo(() => ({
    user,
    loading,
    preferences,
    isAuthenticated: !!user,
    isAdmin: user?.role === 'admin'
  }), [user, loading, preferences]);

  return (
    <UserActionsContext.Provider value={actions}>
      <UserDataContext.Provider value={userData}>
        {children}
      </UserDataContext.Provider>
    </UserActionsContext.Provider>
  );
}

// Components subscribe only to what they need
function UserProfile() {
  const { user, loading } = useContext(UserDataContext);
  // Only re-renders when user data changes, not when actions change
  
  if (loading) return <div>Loading...</div>;
  
  return (
    <div className="user-profile">
      <h2>{user?.name}</h2>
      <p>{user?.email}</p>
    </div>
  );
}

function UserActions() {
  const { logout, updateUser } = useContext(UserActionsContext);
  // Never re-renders due to user data changes
  
  return (
    <div className="user-actions">
      <button onClick={logout}>Logout</button>
      <button onClick={() => updateUser({ lastActive: new Date() })}>
        Update Activity
      </button>
    </div>
  );
}
```
:::

## Multi-Tenant Provider Architecture

For applications that need to support multiple contexts or tenants, advanced provider patterns can manage isolated state while sharing common services.

::: example
```jsx
// Multi-tenant provider system
function createTenantProvider(tenantId) {
  return function TenantProvider({ children }) {
    const [tenantData, setTenantData] = useState(null);
    const [loading, setLoading] = useState(true);
    const globalServices = useServices();

    useEffect(() => {
      globalServices.api.getTenant(tenantId)
        .then(setTenantData)
        .finally(() => setLoading(false));
    }, [tenantId, globalServices.api]);

    const tenantServices = useMemo(() => ({
      ...globalServices,
      tenantAPI: new TenantSpecificAPI(tenantId, globalServices.httpClient),
      tenantConfig: tenantData?.config || {},
      tenantId
    }), [globalServices, tenantData, tenantId]);

    if (loading) return <div>Loading tenant...</div>;

    return (
      <TenantContext.Provider value={tenantServices}>
        {children}
      </TenantContext.Provider>
    );
  };
}

// Workspace isolation provider
function WorkspaceProvider({ workspaceId, children }) {
  const tenant = useTenant();
  const [workspace, setWorkspace] = useState(null);
  const [permissions, setPermissions] = useState({});

  useEffect(() => {
    Promise.all([
      tenant.tenantAPI.getWorkspace(workspaceId),
      tenant.tenantAPI.getWorkspacePermissions(workspaceId)
    ]).then(([workspaceData, permissionsData]) => {
      setWorkspace(workspaceData);
      setPermissions(permissionsData);
    });
  }, [workspaceId, tenant.tenantAPI]);

  const workspaceServices = useMemo(() => ({
    ...tenant,
    workspace,
    permissions,
    workspaceAPI: new WorkspaceAPI(workspaceId, tenant.tenantAPI)
  }), [tenant, workspace, permissions, workspaceId]);

  return (
    <WorkspaceContext.Provider value={workspaceServices}>
      {children}
    </WorkspaceContext.Provider>
  );
}

// Usage with nested providers
function App() {
  const tenantId = useCurrentTenant();
  const workspaceId = useCurrentWorkspace();
  
  const TenantProvider = createTenantProvider(tenantId);

  return (
    <GlobalServicesProvider>
      <TenantProvider>
        <WorkspaceProvider workspaceId={workspaceId}>
          <Dashboard />
        </WorkspaceProvider>
      </TenantProvider>
    </GlobalServicesProvider>
  );
}
```
:::

## Event-Driven Provider Patterns

Advanced provider architectures can incorporate event-driven patterns for loose coupling and reactive updates.

::: example
```jsx
// Event bus provider for loose coupling
function EventBusProvider({ children }) {
  const eventBus = useMemo(() => {
    const listeners = new Map();

    const on = (event, callback) => {
      if (!listeners.has(event)) {
        listeners.set(event, new Set());
      }
      listeners.get(event).add(callback);

      // Return unsubscribe function
      return () => {
        listeners.get(event)?.delete(callback);
      };
    };

    const emit = (event, data) => {
      const eventListeners = listeners.get(event);
      if (eventListeners) {
        eventListeners.forEach(callback => {
          try {
            callback(data);
          } catch (error) {
            console.error(`Error in event listener for ${event}:`, error);
          }
        });
      }
    };

    const once = (event, callback) => {
      const unsubscribe = on(event, (data) => {
        callback(data);
        unsubscribe();
      });
      return unsubscribe;
    };

    return { on, emit, once };
  }, []);

  return (
    <EventBusContext.Provider value={eventBus}>
      {children}
    </EventBusContext.Provider>
  );
}

// Practice session provider with event integration
function PracticeSessionProvider({ children }) {
  const [currentSession, setCurrentSession] = useState(null);
  const [sessionHistory, setSessionHistory] = useState([]);
  const eventBus = useEventBus();
  const api = useAPI();

  // Listen for session events
  useEffect(() => {
    const unsubscribeStart = eventBus.on('session:start', async (sessionData) => {
      const session = await api.createSession(sessionData);
      setCurrentSession(session);
      eventBus.emit('session:created', session);
    });

    const unsubscribeComplete = eventBus.on('session:complete', async (sessionId) => {
      const completedSession = await api.completeSession(sessionId);
      setCurrentSession(null);
      setSessionHistory(prev => [completedSession, ...prev]);
      eventBus.emit('session:completed', completedSession);
    });

    return () => {
      unsubscribeStart();
      unsubscribeComplete();
    };
  }, [eventBus, api]);

  const contextValue = {
    currentSession,
    sessionHistory,
    startSession: (sessionData) => eventBus.emit('session:start', sessionData),
    completeSession: (sessionId) => eventBus.emit('session:complete', sessionId)
  };

  return (
    <PracticeSessionContext.Provider value={contextValue}>
      {children}
    </PracticeSessionContext.Provider>
  );
}

// Analytics provider that reacts to session events
function AnalyticsProvider({ children }) {
  const eventBus = useEventBus();
  const analytics = useService('analytics');

  useEffect(() => {
    const unsubscribeCreated = eventBus.on('session:created', (session) => {
      analytics.track('practice_session_started', {
        sessionId: session.id,
        piece: session.piece,
        duration: session.targetDuration
      });
    });

    const unsubscribeCompleted = eventBus.on('session:completed', (session) => {
      analytics.track('practice_session_completed', {
        sessionId: session.id,
        actualDuration: session.actualDuration,
        targetDuration: session.targetDuration,
        completion: session.actualDuration / session.targetDuration
      });
    });

    return () => {
      unsubscribeCreated();
      unsubscribeCompleted();
    };
  }, [eventBus, analytics]);

  return <>{children}</>;
}
```
:::

## When to Use Advanced Provider Patterns

Advanced provider patterns work best for:

- Large applications with complex state management needs
- Multi-tenant or multi-workspace applications
- Applications requiring sophisticated dependency injection
- Systems with many cross-cutting concerns
- Applications that need to coordinate between multiple isolated contexts

::: tip
**Provider architecture principles**

- Keep providers focused on a single concern or domain
- Use hierarchical composition for complex dependency relationships
- Split frequently changing data from stable configuration
- Implement proper error boundaries around provider trees
- Consider performance implications of context value changes
- Use event-driven patterns for loose coupling between providers
:::

::: caution
**Complexity management**

Advanced provider patterns add significant complexity to your application architecture. Use them when the benefits clearly outweigh the costs, and ensure your team understands the patterns before implementing them in production code.
:::
