# Building React applications

Now that you understand React's fundamentals and component thinking, it's time to explore how to actually build complete React applications. This chapter bridges the gap between understanding React concepts and building real-world applications that users can navigate, interact with, and enjoy.

We'll explore the architectural decisions that define modern React applications: the shift from traditional multi-page applications to single page applications (SPAs), the critical role of client-side routing, the build tools that make React development efficient, and the styling approaches that make your applications beautiful and maintainable.

These topics might seem unrelated to React's core concepts, but they're essential for building applications that users actually want to use. A React application without proper routing feels broken. A React application without a proper build setup is difficult to develop and deploy. A React application without thoughtful styling looks unprofessional and is hard to use.

::: important
**Why this chapter matters**

This chapter covers the practical foundations that every React developer needs:

- **Understanding SPAs**: Why single page applications have become the standard and how they differ from traditional websites
- **Mastering routing**: How to create seamless navigation experiences with React Router
- **Build tools**: Setting up efficient development environments with Create React App, Vite, and custom configurations
- **Styling strategies**: Choosing and implementing styling solutions that scale with your application

These aren't just technical details. They're architectural decisions that will shape your entire development experience.
:::

## Single page applications: the foundation of modern web apps

Before diving into React-specific techniques, we need to understand the fundamental shift that React applications represent: the move from traditional multi-page applications to single page applications (SPAs).

### Understanding traditional multi-page applications {.unnumbered .unlisted}

Traditional web applications work like a series of separate documents. When you click a link or submit a form, your browser makes a request to the server, which responds with a completely new HTML page. Your browser then discards the current page and renders the new one from scratch.

::: example
**Traditional Multi-Page Application Flow**

```
User clicks "About" link
  |
Browser sends request to server (/about)
  |
Server generates HTML for about page
  |
Browser receives new HTML page
  |
Browser discards current page and renders new page
  |
Page load complete (full refresh)
```
:::

This approach has some advantages:

- **Simple to understand**: Each page is a separate document
- **SEO friendly**: Search engines can easily crawl and index each page
- **Browser history works naturally**: Back/forward buttons work as expected
- **Progressive enhancement**: Works even with JavaScript disabled

But it also has significant drawbacks:

- **Slow navigation**: Every page change requires a full server round-trip
- **Poor user experience**: Flash/flicker between pages, lost scroll position
- **Inefficient**: Re-downloading CSS, JavaScript, and other assets for each page
- **Difficult state management**: Application state is lost between page loads

### The single page application approach {.unnumbered .unlisted}

Single page applications take a fundamentally different approach. Instead of multiple separate pages, you have one HTML page that updates its content dynamically using JavaScript. When the user navigates, JavaScript updates the URL and changes what's displayed, but the browser never loads a new page.

::: example
**Single Page Application Flow**

```
User clicks "About" link
  |
JavaScript intercepts the click
  |
JavaScript updates the URL (/about)
  |
JavaScript renders new components
  |
Page content updates (no refresh)
```
:::

This provides several advantages:

- **Fast navigation**: No server round-trips for page changes
- **Smooth user experience**: No flickers, maintained scroll position
- **Efficient resource usage**: CSS/JavaScript loaded once and reused
- **Rich interactions**: Complex UI states and animations possible
- **App-like feel**: Users expect this from modern web applications

But SPAs also introduce new challenges:

- **Complex routing**: JavaScript must manage URL changes and browser history
- **SEO considerations**: Search engines need special handling for dynamic content
- **Initial load time**: Larger JavaScript bundles take time to download
- **Browser history management**: Back/forward buttons need special handling

### Why React and SPAs are perfect together {.unnumbered .unlisted}

React's component-based architecture and declarative approach make it ideal for building SPAs. Here's why:

**Component reusability**: The same components can be used across different "pages" of your SPA, reducing duplication and improving consistency.

**State preservation**: React can maintain application state as users navigate, creating smoother experiences.

**Efficient updates**: React's virtual DOM ensures that only the parts of the page that actually change get updated.

**Rich interactions**: React's event handling and state management enable complex user interactions that would be difficult in traditional multi-page apps.

::: important
**The navigation experience**

The key difference between SPAs and traditional web apps is the navigation experience. In a well-built SPA, clicking a link feels instant because you're just changing what React components are rendered. In a traditional web app, there's always that moment of waiting for the new page to load.

This difference might seem small, but it fundamentally changes how users interact with your application. SPAs feel more like native applications, which is why they've become the standard for modern web development.
:::

## React Router: bringing navigation to life

Now that you understand why SPAs need special routing solutions, let's explore React Router: the de facto standard for handling navigation in React applications.

React Router enables declarative, component-based routing that maintains React's compositional patterns. Instead of having a separate routing configuration file, you define routes using React components, making your routing logic part of your component tree.

### Essential React Router Setup {.unnumbered .unlisted}

Let's start with a complete, working example that demonstrates the core concepts:

::: example
**Basic React Router Implementation**

```jsx
// App.js - Basic routing setup
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
  Link,
  NavLink,
  useNavigate,
  useParams,
  useLocation
} from 'react-router-dom'

// Page components
import HomePage from './pages/HomePage'
import AboutPage from './pages/AboutPage'
import UserProfile from './pages/UserProfile'
import ProductDetail from './pages/ProductDetail'
import NotFound from './pages/NotFound'
import Navigation from './components/Navigation'

function App() {
  return (
    <Router>
      <div className="app">
        <Navigation />
        <main className="main-content">
          <Routes>
            {/* Basic routes */}
            <Route path="/" element={<HomePage />} />
            <Route path="/about" element={<AboutPage />} />
            
            {/* Parameterized routes */}
            <Route path="/user/:userId" element={<UserProfile />} />
            <Route path="/product/:productId" element={<ProductDetail />} />
            
            {/* Nested routes */}
            <Route path="/dashboard/*" element={<Dashboard />} />
            
            {/* Redirects */}
            <Route path="/home" element={<Navigate to="/" replace />} />
            
            {/* Catch-all route for 404s */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </main>
      </div>
    </Router>
  )
}

// Navigation component with active link styling
function Navigation() {
  return (
    <nav className="navigation">
      <Link to="/" className="nav-logo">
        My App
      </Link>
      
      <ul className="nav-links">
        <li>
          <NavLink 
            to="/" 
            className={({ isActive }) => 
              isActive ? 'nav-link active' : 'nav-link'
            }
          >
            Home
          </NavLink>
        </li>
        <li>
          <NavLink 
            to="/about"
            className={({ isActive }) => 
              isActive ? 'nav-link active' : 'nav-link'
            }
          >
            About
          </NavLink>
        </li>
        <li>
          <NavLink 
            to="/dashboard"
            className={({ isActive }) => 
              isActive ? 'nav-link active' : 'nav-link'
            }
          >
            Dashboard
          </NavLink>
        </li>
      </ul>
    </nav>
  )
}

export default App
```
:::

### Understanding React Router Components {.unnumbered .unlisted}

Let's break down the key components and concepts:

**BrowserRouter (Router)**: The foundation component that enables routing in your app. It uses the HTML5 history API to keep your UI in sync with the URL.

**Routes**: A container that holds all your individual route definitions. It determines which route to render based on the current URL.

**Route**: Defines a mapping between a URL path and a component. When the URL matches the path, React Router renders the specified component.

**Link**: Creates navigation links that update the URL without causing a page refresh. Use this instead of regular `<a>` tags.

**NavLink**: Like Link, but with additional features for styling active links.

### Working with URL Parameters {.unnumbered .unlisted}

One of React Router's most powerful features is the ability to capture parts of the URL as parameters:

::: example
**Using URL Parameters**

```jsx
// In your route definition
<Route path="/user/:userId" element={<UserProfile />} />
<Route path="/product/:productId/review/:reviewId" element={<ReviewDetail />} />

// In your component
import { useParams } from 'react-router-dom'

function UserProfile() {
  const { userId } = useParams()
  const [user, setUser] = useState(null)
  
  useEffect(() => {
    // Fetch user data using the userId from the URL
    fetchUser(userId)
      .then(setUser)
      .catch(error => console.error('Failed to load user:', error))
  }, [userId])

  if (!user) {
    return <div className="loading">Loading user profile...</div>
  }

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <img src={user.avatar} alt={`${user.name}'s avatar`} />
      <p>{user.bio}</p>
    </div>
  )
}

// Multiple parameters
function ReviewDetail() {
  const { productId, reviewId } = useParams()
  
  // Use both productId and reviewId to fetch and display the review
  // ...
}
```
:::

URL parameters are essential for creating bookmarkable, shareable URLs. When a user visits `/user/123`, your component automatically receives `123` as the `userId` parameter.

### Programmatic Navigation {.unnumbered .unlisted}

Sometimes you need to navigate programmatically (for example, after a form submission or when certain conditions are met):

::: example
**Programmatic Navigation**

```jsx
import { useNavigate, useLocation } from 'react-router-dom'

function LoginForm() {
  const navigate = useNavigate()
  const location = useLocation()
  
  // Get the page the user was trying to access before login
  const from = location.state?.from?.pathname || '/dashboard'

  const handleLogin = async (credentials) => {
    try {
      await login(credentials)
      // Redirect to the page they were trying to access
      navigate(from, { replace: true })
    } catch (error) {
      setError('Invalid credentials')
    }
  }

  return (
    <form onSubmit={handleLogin}>
      {/* form fields */}
    </form>
  )
}

function UserProfile() {
  const navigate = useNavigate()
  
  const handleDeleteAccount = async () => {
    if (confirm('Are you sure you want to delete your account?')) {
      await deleteUser()
      // Redirect to home page after deletion
      navigate('/', { replace: true })
    }
  }

  const handleEditProfile = () => {
    // Navigate to edit page, preserving current location in state
    navigate('/edit-profile', { 
      state: { from: location.pathname } 
    })
  }

  return (
    <div>
      {/* profile content */}
      <button onClick={handleEditProfile}>Edit Profile</button>
      <button onClick={handleDeleteAccount}>Delete Account</button>
    </div>
  )
}
```
:::

### Advanced Routing Patterns {.unnumbered .unlisted}

As your application grows, you'll need more sophisticated routing patterns:

::: example
**Nested Routes and Layouts**

```jsx
// Dashboard with nested routes
function Dashboard() {
  return (
    <div className="dashboard-layout">
      <aside className="dashboard-sidebar">
        <nav className="dashboard-nav">
          <NavLink to="/dashboard" end>Overview</NavLink>
          <NavLink to="/dashboard/profile">Profile</NavLink>
          <NavLink to="/dashboard/settings">Settings</NavLink>
          <NavLink to="/dashboard/analytics">Analytics</NavLink>
        </nav>
      </aside>
      
      <main className="dashboard-content">
        <Routes>
          <Route index element={<DashboardOverview />} />
          <Route path="profile" element={<ProfileManagement />} />
          <Route path="settings" element={<UserSettings />} />
          <Route path="analytics" element={<AnalyticsDashboard />} />
        </Routes>
      </main>
    </div>
  )
}

// Protected routes that require authentication
function ProtectedRoute({ children }) {
  const { user, loading } = useAuth()
  const location = useLocation()

  if (loading) {
    return <div className="loading-spinner">Loading...</div>
  }

  if (!user) {
    // Redirect to login with return path
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  return children
}

// Usage in your main App component
function App() {
  return (
    <Router>
      <Routes>
        {/* Public routes */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/" element={<HomePage />} />
        
        {/* Protected routes */}
        <Route 
          path="/dashboard/*" 
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          } 
        />
        
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  )
}
```
:::

### Loading States and Code Splitting {.unnumbered .unlisted}

Modern React applications often use code splitting to reduce initial bundle size. React Router works beautifully with React's lazy loading:

::: example
**Lazy Loading with React Router**

```jsx
import { lazy, Suspense } from 'react'

// Lazy-loaded components
const Dashboard = lazy(() => import('./pages/Dashboard'))
const AdminPanel = lazy(() => import('./pages/AdminPanel'))
const Analytics = lazy(() => import('./pages/Analytics'))

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        
        {/* Lazy-loaded routes with loading fallback */}
        <Route 
          path="/dashboard/*" 
          element={
            <Suspense fallback={<div className="page-loading">Loading Dashboard...</div>}>
              <Dashboard />
            </Suspense>
          } 
        />
        
        <Route 
          path="/admin/*" 
          element={
            <ProtectedRoute requiredRole="admin">
              <Suspense fallback={<div className="page-loading">Loading Admin Panel...</div>}>
                <AdminPanel />
              </Suspense>
            </ProtectedRoute>
          } 
        />
      </Routes>
    </Router>
  )
}
```
:::

## Build Tools: Setting Up Your Development Environment

React applications require a build process to transform JSX, handle modules, optimize assets, and create production-ready bundles. While you could set this up manually, several tools make this process much easier.

### Create React App: The Traditional Starting Point {.unnumbered .unlisted}

Create React App (CRA) has been the go-to solution for React applications for years. It provides a complete development environment with zero configuration:

::: example
**Getting Started with Create React App**

```bash
# Create a new React application
npx create-react-app my-react-app
cd my-react-app

# Start the development server
npm start

# Build for production
npm run build

# Run tests
npm test
```

**What CRA provides:**

- Development server with hot reloading
- JSX and ES6+ transformation
- CSS preprocessing and autoprefixing
- Optimized production builds
- Testing setup with Jest
- PWA features and service workers
:::

CRA handles complex webpack configuration behind the scenes, allowing you to focus on building your application rather than configuring build tools.

### Vite: The Modern Alternative {.unnumbered .unlisted}

Vite (pronounced "veet") has emerged as a faster, more modern alternative to Create React App. It leverages native ES modules and esbuild for significantly faster development builds:

::: example
**Getting Started with Vite**

```bash
# Create a new React application with Vite
npm create vite@latest my-react-app -- --template react
cd my-react-app
npm install

# Start the development server
npm run dev

# Build for production
npm run build

# Preview the production build
npm run preview
```

**Why Vite is becoming popular:**

- Much faster development server startup
- Instant hot module replacement (HMR)
- Smaller, more focused tool
- Modern ES modules approach
- Better TypeScript support
- More flexible configuration
:::

### Understanding the Build Process {.unnumbered .unlisted}

Regardless of which tool you choose, the build process performs several crucial transformations:

::: important
**What happens during the build process**

1. **JSX Transformation**: Converts JSX syntax into regular JavaScript function calls
2. **Module Bundling**: Combines separate files into optimized bundles
3. **Code Splitting**: Separates code into chunks that can be loaded on demand
4. **Asset Optimization**: Compresses images, CSS, and JavaScript
5. **Environment Variables**: Injects environment-specific configuration
6. **Browser Compatibility**: Transforms modern JavaScript for older browsers
:::

::: example
**Build Process Example**

```jsx
// What you write:
function App() {
  return <div className="app">Hello World</div>
}

// What the build tool outputs (simplified):
function App() {
  return React.createElement("div", { className: "app" }, "Hello World")
}
```
:::

### Custom Webpack Configuration {.unnumbered .unlisted}

For more control, you can eject from Create React App or set up a custom webpack configuration:

::: example
**Basic Webpack Configuration for React**

```javascript
// webpack.config.js
const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].[contenthash].js',
    clean: true
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-react']
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html'
    })
  ],
  resolve: {
    extensions: ['.js', '.jsx']
  },
  devServer: {
    contentBase: './dist',
    hot: true
  }
}
```
:::

### Environment Configuration {.unnumbered .unlisted}

Modern React applications need different configurations for development, testing, and production:

::: example
**Environment Variables**

```bash
# .env.local
REACT_APP_API_URL=http://localhost:3001
REACT_APP_ANALYTICS_ID=dev-12345
REACT_APP_FEATURE_FLAG_NEW_UI=true

# .env.production
REACT_APP_API_URL=https://api.myapp.com
REACT_APP_ANALYTICS_ID=prod-67890
REACT_APP_FEATURE_FLAG_NEW_UI=false
```

```jsx
// Using environment variables in your components
function App() {
  const apiUrl = process.env.REACT_APP_API_URL
  const showNewUI = process.env.REACT_APP_FEATURE_FLAG_NEW_UI === 'true'
  
  return (
    <div className="app">
      {showNewUI ? <NewDashboard /> : <LegacyDashboard />}
    </div>
  )
}
```
:::

## Styling React Applications

Styling React applications requires careful consideration of maintainability, scalability, and developer experience. Let's explore the most effective approaches.

### CSS Modules: Scoped Styling {.unnumbered .unlisted}

CSS Modules provide locally scoped CSS classes, preventing the global nature of CSS from causing conflicts:

::: example
**CSS Modules Example**

```css
/* Button.module.css */
.button {
  padding: 12px 24px;
  border: none;
  border-radius: 4px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.primary {
  background-color: #3b82f6;
  color: white;
}

.secondary {
  background-color: #e5e7eb;
  color: #374151;
}

.button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
```

```jsx
// Button.jsx
import styles from './Button.module.css'

function Button({ variant = 'primary', children, ...props }) {
  const className = `${styles.button} ${styles[variant]}`
  
  return (
    <button className={className} {...props}>
      {children}
    </button>
  )
}

// Usage
function App() {
  return (
    <div>
      <Button variant="primary">Primary Button</Button>
      <Button variant="secondary">Secondary Button</Button>
    </div>
  )
}
```
:::

### Styled Components: CSS-in-JS {.unnumbered .unlisted}

Styled Components brings CSS into your JavaScript, enabling dynamic styling based on props:

::: example
**Styled Components Example**

```jsx
import styled from 'styled-components'

const Button = styled.button`
  padding: 12px 24px;
  border: none;
  border-radius: 4px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  
  background-color: ${props => 
    props.variant === 'primary' ? '#3b82f6' : '#e5e7eb'
  };
  
  color: ${props => 
    props.variant === 'primary' ? 'white' : '#374151'
  };
  
  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }
  
  ${props => props.disabled && `
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
  `}
`

// Usage
function App() {
  return (
    <div>
      <Button variant="primary">Primary Button</Button>
      <Button variant="secondary" disabled>Disabled Button</Button>
    </div>
  )
}
```
:::

### Tailwind CSS: Utility-First Styling {.unnumbered .unlisted}

Tailwind CSS provides low-level utility classes that you combine to build custom designs:

::: example
**Tailwind CSS Example**

```jsx
function Button({ variant = 'primary', disabled, children, ...props }) {
  const baseClasses = 'px-6 py-3 rounded-md font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2'
  
  const variantClasses = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500'
  }
  
  const disabledClasses = disabled ? 'opacity-60 cursor-not-allowed' : 'hover:-translate-y-0.5 hover:shadow-lg'
  
  const className = `${baseClasses} ${variantClasses[variant]} ${disabledClasses}`
  
  return (
    <button className={className} disabled={disabled} {...props}>
      {children}
    </button>
  )
}

// Card component example
function Card({ children, className = '' }) {
  return (
    <div className={`bg-white rounded-lg shadow-md p-6 ${className}`}>
      {children}
    </div>
  )
}

// Layout example
function Dashboard() {
  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <h1 className="text-xl font-semibold text-gray-900">Dashboard</h1>
            <Button variant="primary">New Project</Button>
          </div>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Card>
            <h2 className="text-lg font-medium text-gray-900 mb-2">Projects</h2>
            <p className="text-3xl font-bold text-blue-600">24</p>
          </Card>
          <Card>
            <h2 className="text-lg font-medium text-gray-900 mb-2">Team Members</h2>
            <p className="text-3xl font-bold text-green-600">12</p>
          </Card>
          <Card>
            <h2 className="text-lg font-medium text-gray-900 mb-2">Tasks</h2>
            <p className="text-3xl font-bold text-purple-600">156</p>
          </Card>
        </div>
      </main>
    </div>
  )
}
```
:::

### Design System Integration {.unnumbered .unlisted}

For larger applications, consider using established design systems:

::: example
**Using Material-UI (MUI)**

```jsx
import { 
  ThemeProvider, 
  createTheme,
  Button,
  Card,
  CardContent,
  Typography,
  Grid,
  AppBar,
  Toolbar
} from '@mui/material'

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
})

function Dashboard() {
  return (
    <ThemeProvider theme={theme}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Dashboard
          </Typography>
          <Button color="inherit">Login</Button>
        </Toolbar>
      </AppBar>
      
      <Grid container spacing={3} sx={{ p: 3 }}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h5" component="div">
                Projects
              </Typography>
              <Typography variant="h3" color="primary">
                24
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        {/* More cards... */}
      </Grid>
    </ThemeProvider>
  )
}
```
:::

### Choosing the Right Styling Approach {.unnumbered .unlisted}

Consider these factors when choosing a styling approach:

**Team size and experience**: Larger teams often benefit from design systems, while smaller teams might prefer utility frameworks.

**Design consistency**: If you need strict design consistency, CSS-in-JS or design systems provide better control.

**Performance requirements**: CSS Modules and traditional CSS have the smallest runtime overhead.

**Developer experience**: Consider which approach your team finds most productive.

**Maintenance requirements**: Think about how easy it will be to update and maintain styles over time.

::: tip
**Styling recommendation**

For most React applications, I recommend starting with either:

- **Tailwind CSS** for rapid prototyping and utility-based styling
- **CSS Modules** for component-scoped styles with traditional CSS
- **Material-UI or Ant Design** for applications that need comprehensive design systems

Choose based on your team's preferences and project requirements, but avoid mixing too many approaches in the same application.
:::

## Putting It All Together: A Complete React Application

Let's combine everything we've learned into a complete, working React application that demonstrates all the concepts covered in this chapter.

::: example
**Complete Application Example**

```jsx
// App.js
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import { ThemeProvider } from './contexts/ThemeContext'
import Layout from './components/Layout'
import HomePage from './pages/HomePage'
import DashboardPage from './pages/DashboardPage'
import LoginPage from './pages/LoginPage'
import ProfilePage from './pages/ProfilePage'
import ProtectedRoute from './components/ProtectedRoute'
import { Suspense, lazy } from 'react'

// Lazy-loaded components
const AdminPage = lazy(() => import('./pages/AdminPage'))
const SettingsPage = lazy(() => import('./pages/SettingsPage'))

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <Router>
          <div className="app">
            <Routes>
              {/* Public routes */}
              <Route path="/login" element={<LoginPage />} />
              
              {/* Routes with layout */}
              <Route path="/" element={<Layout />}>
                <Route index element={<HomePage />} />
                
                {/* Protected routes */}
                <Route 
                  path="/dashboard" 
                  element={
                    <ProtectedRoute>
                      <DashboardPage />
                    </ProtectedRoute>
                  } 
                />
                
                <Route 
                  path="/profile" 
                  element={
                    <ProtectedRoute>
                      <ProfilePage />
                    </ProtectedRoute>
                  } 
                />
                
                {/* Lazy-loaded protected routes */}
                <Route 
                  path="/settings" 
                  element={
                    <ProtectedRoute>
                      <Suspense fallback={<div>Loading Settings...</div>}>
                        <SettingsPage />
                      </Suspense>
                    </ProtectedRoute>
                  } 
                />
                
                <Route 
                  path="/admin" 
                  element={
                    <ProtectedRoute requiredRole="admin">
                      <Suspense fallback={<div>Loading Admin Panel...</div>}>
                        <AdminPage />
                      </Suspense>
                    </ProtectedRoute>
                  } 
                />
              </Route>
              
              {/* Redirects and 404 */}
              <Route path="/home" element={<Navigate to="/" replace />} />
              <Route path="*" element={<div>Page Not Found</div>} />
            </Routes>
          </div>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  )
}

export default App
```

```jsx
// components/Layout.js
import { Outlet } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'

function Layout() {
  return (
    <div className="layout">
      <Navigation />
      <main className="main-content">
        <Outlet />
      </main>
      <Footer />
    </div>
  )
}

export default Layout
```

```jsx
// components/Navigation.js
import { NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import styles from './Navigation.module.css'

function Navigation() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/')
  }

  return (
    <nav className={styles.navigation}>
      <div className={styles.container}>
        <NavLink to="/" className={styles.logo}>
          My App
        </NavLink>
        
        <ul className={styles.navLinks}>
          <li>
            <NavLink 
              to="/" 
              className={({ isActive }) => 
                isActive ? `${styles.navLink} ${styles.active}` : styles.navLink
              }
            >
              Home
            </NavLink>
          </li>
          
          {user && (
            <>
              <li>
                <NavLink 
                  to="/dashboard" 
                  className={({ isActive }) => 
                    isActive ? `${styles.navLink} ${styles.active}` : styles.navLink
                  }
                >
                  Dashboard
                </NavLink>
              </li>
              <li>
                <NavLink 
                  to="/profile" 
                  className={({ isActive }) => 
                    isActive ? `${styles.navLink} ${styles.active}` : styles.navLink
                  }
                >
                  Profile
                </NavLink>
              </li>
            </>
          )}
        </ul>
        
        <div className={styles.userSection}>
          {user ? (
            <div className={styles.userMenu}>
              <span>Welcome, {user.name}</span>
              <button onClick={handleLogout} className={styles.logoutButton}>
                Logout
              </button>
            </div>
          ) : (
            <NavLink to="/login" className={styles.loginButton}>
              Login
            </NavLink>
          )}
        </div>
      </div>
    </nav>
  )
}

export default Navigation
```
:::

This complete example demonstrates:

- **SPA architecture** with client-side routing
- **React Router** for navigation and URL management
- **Protected routes** for authentication
- **Lazy loading** for performance optimization
- **CSS Modules** for component-scoped styling
- **Context providers** for global state management
- **Proper component organization** and separation of concerns

## Chapter Summary

In this chapter, we've explored the essential foundations for building real-world React applications:

**Single Page Applications**: Understanding why SPAs have become the standard for modern web applications and how they differ from traditional multi-page applications.

**React Router**: Mastering client-side routing to create seamless navigation experiences with declarative, component-based routing patterns.

**Build Tools**: Setting up efficient development environments with Create React App, Vite, and understanding the build process that transforms your code for production.

**Styling Strategies**: Choosing and implementing styling solutions that scale with your application, from CSS Modules to CSS-in-JS to utility frameworks.

These aren't just technical details. They're architectural decisions that will shape your entire development experience. A React application without proper routing feels broken. A React application without a proper build setup is difficult to develop and deploy. A React application without thoughtful styling looks unprofessional and is hard to use.

The next chapter will dive deep into state and props: the mechanisms that make your components dynamic and interactive. We'll explore how to manage data flow effectively and create components that communicate cleanly with each other.

::: important
**Looking ahead**

Now that you understand how to structure and build React applications, we'll focus on making them dynamic and interactive. Chapter 3 will cover:

- Managing component state effectively
- Designing clean prop interfaces between components
- Handling data fetching and API integration
- Creating predictable data flow patterns
- Dealing with forms and user input

These concepts build directly on the architectural foundations we've established in this chapter.
:::
