# Context Patterns for Architectural Dependencies

React Context extends far beyond simple data passing—it serves as a powerful architectural tool for implementing dependency injection patterns that enhance application structure, testability, and maintainability. Context-based dependency injection eliminates prop drilling, simplifies component testing, and establishes clear separation between business logic and presentation concerns.

Dependency injection is a design pattern where objects receive their dependencies from external sources rather than creating them internally. In React applications, this pattern prevents prop drilling complications, simplifies testing scenarios, and creates clear architectural boundaries between different application concerns.

::: important
**Context vs. Prop Drilling Trade-offs**

Context excels at resolving the "prop drilling" problem where props must traverse multiple component levels to reach deeply nested children. However, Context requires judicious application—not every shared state warrants Context usage. Consider Context when you have genuinely application-wide concerns or when prop drilling becomes architecturally unwieldy.
:::

## Traditional Dependency Injection with Context

Consider how a music practice application might inject various services throughout the component tree:

::: example
```jsx
// Traditional prop drilling approach (becomes unwieldy)
function App() {
  const apiService = new PracticeAPIService();
  const analyticsService = new AnalyticsService();
  const storageService = new StorageService();
  
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
      />
      <SessionPlayer 
        apiService={apiService}
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
    storage: new StorageService(),
    notifications: new NotificationService()
  };

  return (
    <ServicesProvider services={services}>
      <Dashboard />
    </ServicesProvider>
  );
}

function useServices() {
  const context = useContext(ServicesContext);
  if (!context) {
    throw new Error('useServices must be used within a ServicesProvider');
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

## Service Container Implementation with Context

A service container functions as a centralized registry that manages the creation and lifecycle of application services. This pattern proves particularly valuable for managing API clients, analytics services, storage adapters, and other cross-cutting architectural concerns.

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
    // API implementation
  }

  async createSession(sessionData) {
    // API implementation
  }
}

class AnalyticsService {
  constructor(trackingId) {
    this.trackingId = trackingId;
  }

  track(event, properties) {
    // Analytics implementation
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
}

class NotificationService {
  show(message, type = 'info') {
    // Notification implementation
  }
}

// Service container context
const ServiceContext = createContext();

export function ServiceProvider({ children, config = {} }) {
  const services = useMemo(() => {
    const api = new PracticeAPIService(
      config.apiBaseURL || '/api',
      config.authToken
    );
    
    const analytics = new AnalyticsService(
      config.analyticsTrackingId
    );
    
    const storage = new StorageService();
    
    const notifications = new NotificationService();

    return {
      api,
      analytics,
      storage,
      notifications
    };
  }, [config]);

  return (
    <ServiceContext.Provider value={services}>
      {children}
    </ServiceContext.Provider>
  );
}

export function useServices() {
  const context = useContext(ServiceContext);
  if (!context) {
    throw new Error('useServices must be used within a ServiceProvider');
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

## Multi-Context State Management Architectures

Complex applications require multiple Context providers that collaborate to manage different aspects of application state and services effectively.

::: example
```jsx
// User authentication context
const AuthContext = createContext();

function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const api = useAPI();

  useEffect(() => {
    api.getCurrentUser()
      .then(setUser)
      .catch(() => setUser(null))
      .finally(() => setLoading(false));
  }, [api]);

  const login = async (credentials) => {
    const user = await api.login(credentials);
    setUser(user);
    return user;
  };

  const logout = async () => {
    await api.logout();
    setUser(null);
  };

  const value = {
    user,
    loading,
    login,
    logout,
    isAuthenticated: !!user
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
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// Practice data context that depends on auth
const PracticeDataContext = createContext();

function PracticeDataProvider({ children }) {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(false);
  const { user } = useAuth();
  const api = useAPI();

  useEffect(() => {
    if (user) {
      setLoading(true);
      api.getSessions(user.id)
        .then(setSessions)
        .finally(() => setLoading(false));
    } else {
      setSessions([]);
    }
  }, [user, api]);

  const createSession = async (sessionData) => {
    const newSession = await api.createSession({
      ...sessionData,
      userId: user.id
    });
    setSessions(prev => [newSession, ...prev]);
    return newSession;
  };

  const value = {
    sessions,
    loading,
    createSession
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
    throw new Error('usePracticeData must be used within a PracticeDataProvider');
  }
  return context;
}

// App setup with multiple providers
function App() {
  return (
    <ServiceProvider config={{ apiBaseURL: '/api' }}>
      <AuthProvider>
        <PracticeDataProvider>
          <Dashboard />
        </PracticeDataProvider>
      </AuthProvider>
    </ServiceProvider>
  );
}
```
:::

## Hierarchical Provider Architecture

Complex applications benefit from hierarchical provider structures that enable granular control over dependencies and state scope. This architectural pattern allows different application sections to access distinct sets of services and state management.

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
      return <Provider>{acc}</Provider>;
    }, children);
  };

  return { registerProvider, buildProviderTree };
}

// Application-specific provider configuration
const AppProviderRegistry = createProviderHierarchy();

function ConfigProvider({ children }) {
  const config = {
    apiBaseURL: process.env.REACT_APP_API_URL,
    analyticsTrackingId: process.env.REACT_APP_ANALYTICS_ID
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

  // Memoize actions to prevent unnecessary re-renders
  const actions = useMemo(() => ({
    login: async (credentials) => {
      const user = await api.login(credentials);
      setUser(user);
    },
    logout: async () => {
      await api.logout();
      setUser(null);
    },
    updateUser: (updates) => {
      setUser(prev => ({ ...prev, ...updates }));
    }
  }), []);

  // Memoize data to prevent unnecessary re-renders
  const userData = useMemo(() => ({
    user,
    loading,
    isAuthenticated: !!user
  }), [user, loading]);

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
  // Only re-renders when user data changes
}

function UserActions() {
  const { login, logout } = useContext(UserActionsContext);
  // Never re-renders due to user data changes
}
```
:::

## When to Use Context for Dependency Injection

Context-based dependency injection works best for:

- Application-wide services like API clients, analytics, and storage
- Cross-cutting concerns like authentication and theming
- Services that need to be easily mocked for testing
- Avoiding deep prop drilling for frequently used dependencies

::: tip
**Context design principles**

- Keep contexts focused on a single concern
- Split frequently changing data from stable configuration
- Use multiple smaller contexts rather than one large context
- Provide clear error messages when contexts are used incorrectly
- Consider performance implications of context value changes
:::

::: caution
**Context overuse**

Not every piece of shared state needs Context. Use Context for truly application-wide concerns. For component-specific state sharing, consider lifting state up or using compound components instead.
:::
