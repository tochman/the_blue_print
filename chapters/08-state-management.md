# State Management Architecture

State management represents one of the most critical architectural decisions in React application development. The landscape includes numerous options—Redux, Zustand, Context, useState, useReducer, MobX, Recoil, Jotai—yet most applications don't require complex state management solutions. The key lies in understanding application requirements and selecting appropriately scaled solutions.

Many developers prematurely adopt complex state management libraries without understanding their application's actual needs. Conversely, some teams avoid external libraries entirely, resulting in unwieldy prop drilling scenarios. Effective state management involves matching solutions to specific application requirements while maintaining the flexibility to evolve as applications grow.

This chapter explores the complete spectrum of state management approaches, from React's built-in capabilities to sophisticated external libraries. You'll learn to make informed architectural decisions about state management, understanding when to use different approaches and how to migrate between solutions as application complexity evolves.

::: tip
**State Management Learning Objectives**

- Develop a comprehensive understanding of state concepts in React applications
- Distinguish between local state and shared state management requirements
- Master React's built-in state management tools and architectural patterns
- Understand when and how to implement external state management libraries
- Apply practical patterns for common state management scenarios
- Plan migration strategies from simple to complex state management solutions
- Optimize state management performance and implement best practices
:::

## State Architecture Fundamentals

Before exploring specific tools and libraries, understanding the nature of state and its role in React applications provides the foundation for making appropriate architectural decisions.

## Defining State in React Applications

State represents any data that changes over time and influences user interface presentation. State categories include:

- **User Interface State**: Modal visibility, selected tabs, scroll positions, and interaction states
- **Form State**: User input values, validation errors, and submission states
- **Application Data**: User profiles, data collections, shopping cart contents, and business logic state
- **Server State**: API-fetched data, loading indicators, error messages, and synchronization states
- **Navigation State**: Current routes, URL parameters, and routing history

Each state category exhibits different characteristics and may benefit from distinct management approaches based on scope, persistence, and performance requirements.

## The State Management Solution Spectrum

State management should be viewed as a spectrum rather than binary choices. Solutions range from simple local component state to sophisticated global state management with advanced debugging capabilities. Most applications require solutions positioned strategically within this spectrum based on specific requirements.

**Local Component State**: Optimal for UI state affecting single components
::: example
```jsx
const [isOpen, setIsOpen] = useState(false);
```
:::

**Shared Local State**: When multiple sibling components require access to identical state

::: example
```jsx
// Lift state up to a common parent
function Parent() {
  const [sharedData, setSharedData] = useState(initialData);
  return (
    <>
      <ChildA data={sharedData} onChange={setSharedData} />
      <ChildB data={sharedData} />
    </>
  );
}
```
:::

**Context for Component Trees**: When many components at different hierarchy levels require access to shared state
```jsx
const ThemeContext = createContext();
```

**Global state management**: When state needs to be accessed from anywhere in the app and persist across navigation
```jsx
// Redux, Zustand, etc.
```

The key insight is that you can start simple and gradually move right on this spectrum as your needs grow.

## React's built-in state management

React provides powerful state management capabilities out of the box. Before reaching for external libraries, let's explore what you can accomplish with React's built-in tools.

### useState: The foundation {.unnumbered .unlisted}`useState` is your go-to tool for local component state. It's simple, predictable, and handles the vast majority of state management needs in most components.

::: example

```jsx
// UserProfile.jsx - Managing form state with useState
import { useState } from 'react';

function UserProfile({ user, onSave }) {
  const [profile, setProfile] = useState({
    name: user.name || '',
    email: user.email || '',
    bio: user.bio || ''
  });
  
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState({});

  const handleFieldChange = (field, value) => {
    setProfile(prev => ({
      ...prev,
      [field]: value
    }));
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: null
      }));
    }
  };

  const validateProfile = () => {
    const newErrors = {};
    
    if (!profile.name.trim()) {
      newErrors.name = 'Name is required';
    }
    
    if (!profile.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(profile.email)) {
      newErrors.email = 'Email is invalid';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSave = async () => {
    if (!validateProfile()) return;
    
    setIsSaving(true);
    try {
      await onSave(profile);
      setIsEditing(false);
    } catch (error) {
      setErrors({ general: 'Failed to save profile' });
    } finally {
      setIsSaving(false);
    }
  };

  if (!isEditing) {
    return (
      <div className="user-profile">
        <h2>{profile.name}</h2>
        <p>{profile.email}</p>
        <p>{profile.bio}</p>
        <button onClick={() => setIsEditing(true)}>Edit Profile</button>
      </div>
    );
  }

  return (
    <form className="user-profile-form">
      <div className="field">
        <label htmlFor="name">Name</label>
        <input
          id="name"
          value={profile.name}
          onChange={(e) => handleFieldChange('name', e.target.value)}
        />
        {errors.name && <span className="error">{errors.name}</span>}
      </div>

      <div className="field">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          value={profile.email}
          onChange={(e) => handleFieldChange('email', e.target.value)}
        />
        {errors.email && <span className="error">{errors.email}</span>}
      </div>

      <div className="field">
        <label htmlFor="bio">Bio</label>
        <textarea
          id="bio"
          value={profile.bio}
          onChange={(e) => handleFieldChange('bio', e.target.value)}
        />
      </div>

      {errors.general && <div className="error">{errors.general}</div>}

      <div className="actions">
        <button 
          type="button" 
          onClick={() => setIsEditing(false)}
          disabled={isSaving}
        >
          Cancel
        </button>
        <button 
          type="button" 
          onClick={handleSave}
          disabled={isSaving}
        >
          {isSaving ? 'Saving...' : 'Save'}
        </button>
      </div>
    </form>
  );
}
```

:::

This example shows `useState` handling multiple related pieces of state. Notice how each piece of state has a clear purpose and the state updates are predictable.

### useReducer: When useState gets complex {.unnumbered .unlisted}

When your component state starts getting complex-especially when you have multiple related pieces of state that change together-`useReducer` can provide better organization and predictability.

::: example

```jsx
// ShoppingCart.jsx - Using useReducer for complex state logic
import { useReducer } from 'react';

const initialCartState = {
  items: [],
  total: 0,
  discountCode: null,
  discountAmount: 0,
  isLoading: false,
  error: null
};

function cartReducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find(item => item.id === action.payload.id);
      
      let newItems;
      if (existingItem) {
        newItems = state.items.map(item =>
          item.id === action.payload.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      } else {
        newItems = [...state.items, { ...action.payload, quantity: 1 }];
      }
      
      return {
        ...state,
        items: newItems,
        total: calculateTotal(newItems, state.discountAmount)
      };
    }
    
    case 'REMOVE_ITEM': {
      const newItems = state.items.filter(item => item.id !== action.payload);
      return {
        ...state,
        items: newItems,
        total: calculateTotal(newItems, state.discountAmount)
      };
    }
    
    case 'UPDATE_QUANTITY': {
      const newItems = state.items.map(item =>
        item.id === action.payload.id
          ? { ...item, quantity: Math.max(0, action.payload.quantity) }
          : item
      ).filter(item => item.quantity > 0);
      
      return {
        ...state,
        items: newItems,
        total: calculateTotal(newItems, state.discountAmount)
      };
    }
    
    case 'APPLY_DISCOUNT_START':
      return {
        ...state,
        isLoading: true,
        error: null
      };
    
    case 'APPLY_DISCOUNT_SUCCESS': {
      const discountAmount = action.payload.amount;
      return {
        ...state,
        discountCode: action.payload.code,
        discountAmount,
        total: calculateTotal(state.items, discountAmount),
        isLoading: false,
        error: null
      };
    }
    
    case 'APPLY_DISCOUNT_ERROR':
      return {
        ...state,
        isLoading: false,
        error: action.payload
      };
    
    case 'CLEAR_CART':
      return initialCartState;
    
    default:
      return state;
  }
}

function calculateTotal(items, discountAmount = 0) {
  const subtotal = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  return Math.max(0, subtotal - discountAmount);
}

function ShoppingCart() {
  const [cartState, dispatch] = useReducer(cartReducer, initialCartState);

  const addItem = (product) => {
    dispatch({ type: 'ADD_ITEM', payload: product });
  };

  const removeItem = (productId) => {
    dispatch({ type: 'REMOVE_ITEM', payload: productId });
  };

  const updateQuantity = (productId, quantity) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { id: productId, quantity } });
  };

  const applyDiscountCode = async (code) => {
    dispatch({ type: 'APPLY_DISCOUNT_START' });
    
    try {
      // Simulate API call
      const response = await fetch(`/api/discounts/${code}`);
      const discount = await response.json();
      
      dispatch({ 
        type: 'APPLY_DISCOUNT_SUCCESS', 
        payload: { code, amount: discount.amount } 
      });
    } catch (error) {
      dispatch({ 
        type: 'APPLY_DISCOUNT_ERROR', 
        payload: 'Invalid discount code' 
      });
    }
  };

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' });
  };

  return (
    <div className="shopping-cart">
      <h2>Shopping Cart</h2>
      
      {cartState.items.length === 0 ? (
        <p>Your cart is empty</p>
      ) : (
        <>
          <div className="cart-items">
            {cartState.items.map(item => (
              <div key={item.id} className="cart-item">
                <span>{item.name}</span>
                <span>${item.price}</span>
                <input
                  type="number"
                  value={item.quantity}
                  onChange={(e) => updateQuantity(item.id, parseInt(e.target.value))}
                  min="0"
                />
                <button onClick={() => removeItem(item.id)}>Remove</button>
              </div>
            ))}
          </div>
          
          <div className="cart-summary">
            {cartState.discountCode && (
              <div>Discount ({cartState.discountCode}): -${cartState.discountAmount}</div>
            )}
            <div className="total">Total: ${cartState.total}</div>
          </div>
          
          <div className="cart-actions">
            <DiscountCodeInput 
              onApply={applyDiscountCode}
              isLoading={cartState.isLoading}
              error={cartState.error}
            />
            <button onClick={clearCart}>Clear Cart</button>
          </div>
        </>
      )}
    </div>
  );
}
```

:::

The key advantage of `useReducer` here is that all the cart logic is centralized in the reducer function. This makes the state updates more predictable and easier to test. When multiple pieces of state need to change together (like when applying a discount), the reducer ensures they stay in sync.

### Context: Sharing state without prop drilling {.unnumbered .unlisted}

React Context is perfect for sharing state that many components need, without passing props through every level of your component tree.

::: example

```jsx
// UserContext.jsx - Managing user authentication state
import { createContext, useContext, useReducer, useEffect } from 'react';

const UserContext = createContext();

const initialState = {
  user: null,
  isAuthenticated: false,
  isLoading: true,
  error: null
};

function userReducer(state, action) {
  switch (action.type) {
    case 'LOGIN_START':
      return {
        ...state,
        isLoading: true,
        error: null
      };
    
    case 'LOGIN_SUCCESS':
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true,
        isLoading: false,
        error: null
      };
    
    case 'LOGIN_ERROR':
      return {
        ...state,
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: action.payload
      };
    
    case 'LOGOUT':
      return {
        ...state,
        user: null,
        isAuthenticated: false,
        error: null
      };
    
    case 'UPDATE_USER':
      return {
        ...state,
        user: { ...state.user, ...action.payload }
      };
    
    default:
      return state;
  }
}

export function UserProvider({ children }) {
  const [state, dispatch] = useReducer(userReducer, initialState);

  useEffect(() => {
    // Check for existing session on app load
    const checkAuthStatus = async () => {
      try {
        const token = localStorage.getItem('authToken');
        if (!token) {
          dispatch({ type: 'LOGIN_ERROR', payload: 'No token found' });
          return;
        }

        const response = await fetch('/api/user/me', {
          headers: { Authorization: `Bearer ${token}` }
        });

        if (response.ok) {
          const user = await response.json();
          dispatch({ type: 'LOGIN_SUCCESS', payload: user });
        } else {
          localStorage.removeItem('authToken');
          dispatch({ type: 'LOGIN_ERROR', payload: 'Invalid token' });
        }
      } catch (error) {
        dispatch({ type: 'LOGIN_ERROR', payload: error.message });
      }
    };

    checkAuthStatus();
  }, []);

  const login = async (email, password) => {
    dispatch({ type: 'LOGIN_START' });
    
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });

      if (response.ok) {
        const { user, token } = await response.json();
        localStorage.setItem('authToken', token);
        dispatch({ type: 'LOGIN_SUCCESS', payload: user });
        return { success: true };
      } else {
        const error = await response.json();
        dispatch({ type: 'LOGIN_ERROR', payload: error.message });
        return { success: false, error: error.message };
      }
    } catch (error) {
      dispatch({ type: 'LOGIN_ERROR', payload: error.message });
      return { success: false, error: error.message };
    }
  };

  const logout = () => {
    localStorage.removeItem('authToken');
    dispatch({ type: 'LOGOUT' });
  };

  const updateUser = (updates) => {
    dispatch({ type: 'UPDATE_USER', payload: updates });
  };

  const value = {
    ...state,
    login,
    logout,
    updateUser
  };

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}

export function useUser() {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
}

// Usage in components
function UserProfile() {
  const { user, updateUser, isLoading } = useUser();

  if (isLoading) return <div>Loading...</div>;
  if (!user) return <div>Please log in</div>;

  return (
    <div>
      <h1>Welcome, {user.name}</h1>
      <button onClick={() => updateUser({ lastActive: new Date() })}>
        Update Activity
      </button>
    </div>
  );
}

function LoginForm() {
  const { login, isLoading, error } = useUser();
  // ... form implementation
}
```

:::

Context is excellent for state that:

- Many components need to access
- Doesn't change very frequently
- Represents "global" application concerns (user auth, theme, etc.)

However, be careful not to put too much in a single context, as any change will re-render all consuming components.

## When to reach for external libraries

React's built-in state management tools are powerful, but there are scenarios where external libraries provide significant benefits. Let me share when I typically reach for them and which libraries I recommend.

### Redux: The heavyweight champion {.unnumbered .unlisted}

Redux gets a bad rap for being verbose, but it shines in specific scenarios. I recommend Redux when you need:

- **Time travel debugging**: The ability to step through state changes
- **Predictable state updates**: Complex applications where bugs are hard to track
- **Server state synchronization**: When you need sophisticated caching and invalidation
- **Team coordination**: Large teams benefit from Redux's strict patterns

Modern Redux with Redux Toolkit (RTK) is much more pleasant to work with than classic Redux:

::: example

```jsx
// store/practiceSessionsSlice.js - Modern Redux with RTK
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { practiceAPI } from '../api/practiceAPI';

// Async thunk for fetching practice sessions
export const fetchPracticeSessions = createAsyncThunk(
  'practiceSessions/fetchSessions',
  async (userId, { rejectWithValue }) => {
    try {
      const response = await practiceAPI.getUserSessions(userId);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const createPracticeSession = createAsyncThunk(
  'practiceSessions/createSession',
  async (sessionData, { rejectWithValue }) => {
    try {
      const response = await practiceAPI.createSession(sessionData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

const practiceSessionsSlice = createSlice({
  name: 'practiceSessions',
  initialState: {
    sessions: [],
    currentSession: null,
    status: 'idle', // 'idle' | 'loading' | 'succeeded' | 'failed'
    error: null,
    filter: 'all', // 'all' | 'recent' | 'favorites'
    sortBy: 'date' // 'date' | 'duration' | 'piece'
  },
  reducers: {
    // Regular synchronous actions
    setCurrentSession: (state, action) => {
      state.currentSession = action.payload;
    },
    clearCurrentSession: (state) => {
      state.currentSession = null;
    },
    setFilter: (state, action) => {
      state.filter = action.payload;
    },
    setSortBy: (state, action) => {
      state.sortBy = action.payload;
    },
    updateSessionLocally: (state, action) => {
      const { id, updates } = action.payload;
      const session = state.sessions.find(s => s.id === id);
      if (session) {
        Object.assign(session, updates);
      }
    }
  },
  extraReducers: (builder) => {
    builder
      // Fetch sessions
      .addCase(fetchPracticeSessions.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchPracticeSessions.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.sessions = action.payload;
      })
      .addCase(fetchPracticeSessions.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload;
      })
      // Create session
      .addCase(createPracticeSession.fulfilled, (state, action) => {
        state.sessions.unshift(action.payload);
      });
  }
});

export const {
  setCurrentSession,
  clearCurrentSession,
  setFilter,
  setSortBy,
  updateSessionLocally
} = practiceSessionsSlice.actions;

// Selectors
export const selectAllSessions = (state) => state.practiceSessions.sessions;
export const selectCurrentSession = (state) => state.practiceSessions.currentSession;
export const selectSessionsStatus = (state) => state.practiceSessions.status;
export const selectSessionsError = (state) => state.practiceSessions.error;

export const selectFilteredSessions = (state) => {
  const { sessions, filter, sortBy } = state.practiceSessions;
  
  let filtered = sessions;
  
  if (filter === 'recent') {
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    filtered = sessions.filter(s => new Date(s.date) > weekAgo);
  } else if (filter === 'favorites') {
    filtered = sessions.filter(s => s.isFavorite);
  }
  
  return filtered.sort((a, b) => {
    switch (sortBy) {
      case 'duration':
        return b.duration - a.duration;
      case 'piece':
        return a.piece.localeCompare(b.piece);
      case 'date':
      default:
        return new Date(b.date) - new Date(a.date);
    }
  });
};

export default practiceSessionsSlice.reducer;
```

```jsx
// components/PracticeSessionList.jsx - Using the Redux state
import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import {
  fetchPracticeSessions,
  selectFilteredSessions,
  selectSessionsStatus,
  selectSessionsError,
  setFilter,
  setSortBy
} from '../store/practiceSessionsSlice';

function PracticeSessionList({ userId }) {
  const dispatch = useDispatch();
  const sessions = useSelector(selectFilteredSessions);
  const status = useSelector(selectSessionsStatus);
  const error = useSelector(selectSessionsError);

  useEffect(() => {
    if (status === 'idle') {
      dispatch(fetchPracticeSessions(userId));
    }
  }, [status, dispatch, userId]);

  const handleFilterChange = (filter) => {
    dispatch(setFilter(filter));
  };

  const handleSortChange = (sortBy) => {
    dispatch(setSortBy(sortBy));
  };

  if (status === 'loading') {
    return <div>Loading practice sessions...</div>;
  }

  if (status === 'failed') {
    return <div>Error: {error}</div>;
  }

  return (
    <div className="practice-session-list">
      <div className="controls">
        <select onChange={(e) => handleFilterChange(e.target.value)}>
          <option value="all">All Sessions</option>
          <option value="recent">Recent</option>
          <option value="favorites">Favorites</option>
        </select>
        
        <select onChange={(e) => handleSortChange(e.target.value)}>
          <option value="date">Sort by Date</option>
          <option value="duration">Sort by Duration</option>
          <option value="piece">Sort by Piece</option>
        </select>
      </div>

      <div className="sessions">
        {sessions.map(session => (
          <PracticeSessionCard key={session.id} session={session} />
        ))}
      </div>
    </div>
  );
}
```

:::

### Zustand: The lightweight alternative {.unnumbered .unlisted}

Zustand is my go-to choice when I need global state management but Redux feels like overkill. It's incredibly simple and has minimal boilerplate:

::: example

```jsx
// stores/practiceStore.js - Simple Zustand store
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';
import { practiceAPI } from '../api/practiceAPI';

export const usePracticeStore = create(
  subscribeWithSelector((set, get) => ({
    // State
    sessions: [],
    currentSession: null,
    isLoading: false,
    error: null,
    
    // Actions
    fetchSessions: async (userId) => {
      set({ isLoading: true, error: null });
      try {
        const sessions = await practiceAPI.getUserSessions(userId);
        set({ sessions, isLoading: false });
      } catch (error) {
        set({ error: error.message, isLoading: false });
      }
    },
    
    addSession: async (sessionData) => {
      try {
        const newSession = await practiceAPI.createSession(sessionData);
        set(state => ({
          sessions: [newSession, ...state.sessions]
        }));
        return newSession;
      } catch (error) {
        set({ error: error.message });
        throw error;
      }
    },
    
    updateSession: async (sessionId, updates) => {
      try {
        const updatedSession = await practiceAPI.updateSession(sessionId, updates);
        set(state => ({
          sessions: state.sessions.map(session =>
            session.id === sessionId ? updatedSession : session
          )
        }));
      } catch (error) {
        set({ error: error.message });
      }
    },
    
    deleteSession: async (sessionId) => {
      try {
        await practiceAPI.deleteSession(sessionId);
        set(state => ({
          sessions: state.sessions.filter(session => session.id !== sessionId)
        }));
      } catch (error) {
        set({ error: error.message });
      }
    },
    
    setCurrentSession: (session) => set({ currentSession: session }),
    clearCurrentSession: () => set({ currentSession: null }),
    clearError: () => set({ error: null })
  }))
);

// Derived state selectors
export const useRecentSessions = () => {
  return usePracticeStore(state => {
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    return state.sessions.filter(s => new Date(s.date) > weekAgo);
  });
};

export const useFavoriteSessions = () => {
  return usePracticeStore(state => 
    state.sessions.filter(s => s.isFavorite)
  );
};
```

```jsx
// components/PracticeSessionList.jsx - Using Zustand
import React, { useEffect } from 'react';
import { usePracticeStore, useRecentSessions } from '../stores/practiceStore';

function PracticeSessionList({ userId }) {
  const {
    sessions,
    isLoading,
    error,
    fetchSessions,
    deleteSession,
    clearError
  } = usePracticeStore();
  
  const recentSessions = useRecentSessions();

  useEffect(() => {
    fetchSessions(userId);
  }, [fetchSessions, userId]);

  const handleDeleteSession = async (sessionId) => {
    if (window.confirm('Are you sure you want to delete this session?')) {
      await deleteSession(sessionId);
    }
  };

  if (isLoading) return <div>Loading...</div>;
  
  if (error) {
    return (
      <div className="error">
        <p>Error: {error}</p>
        <button onClick={clearError}>Dismiss</button>
      </div>
    );
  }

  return (
    <div className="practice-session-list">
      <h2>All Sessions ({sessions.length})</h2>
      <h3>Recent Sessions ({recentSessions.length})</h3>
      
      {sessions.map(session => (
        <div key={session.id} className="session-card">
          <h4>{session.piece}</h4>
          <p>{session.composer}</p>
          <p>{session.duration} minutes</p>
          <button onClick={() => handleDeleteSession(session.id)}>
            Delete
          </button>
        </div>
      ))}
    </div>
  );
}
```

:::

Zustand is perfect when you need:

- Simple global state without boilerplate
- TypeScript support out of the box
- Easy state subscription and derived state
- Minimal learning curve for the team

### Server state: React Query / TanStack Query {.unnumbered .unlisted}

Here's something that took me years to fully appreciate: server state is fundamentally different from client state. Server state is:

- Remote and asynchronous
- Potentially out of date
- Shared ownership (other users can modify it)
- Needs caching, invalidation, and synchronization

React Query (now TanStack Query) is purpose-built for managing server state:

::: example

```jsx
// hooks/usePracticeSessions.js - Server state with React Query
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { practiceAPI } from '../api/practiceAPI';

export function usePracticeSessions(userId) {
  return useQuery({
    queryKey: ['practiceSessions', userId],
    queryFn: () => practiceAPI.getUserSessions(userId),
    staleTime: 5 * 60 * 1000, // Consider fresh for 5 minutes
    cacheTime: 10 * 60 * 1000, // Keep in cache for 10 minutes
    enabled: !!userId // Only run if userId exists
  });
}

export function useCreatePracticeSession() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: practiceAPI.createSession,
    onSuccess: (newSession, variables) => {
      // Optimistically update the cache
      queryClient.setQueryData(
        ['practiceSessions', variables.userId],
        (oldData) => [newSession, ...(oldData || [])]
      );
      
      // Invalidate and refetch
      queryClient.invalidateQueries(['practiceSessions', variables.userId]);
    },
    onError: (error, variables) => {
      // Revert optimistic update if needed
      queryClient.invalidateQueries(['practiceSessions', variables.userId]);
    }
  });
}

export function useDeletePracticeSession() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: practiceAPI.deleteSession,
    onMutate: async (sessionId) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries(['practiceSessions']);
      
      // Snapshot previous value
      const previousSessions = queryClient.getQueryData(['practiceSessions']);
      
      // Optimistically remove the session
      queryClient.setQueriesData(['practiceSessions'], (old) => 
        old?.filter(session => session.id !== sessionId)
      );
      
      return { previousSessions };
    },
    onError: (err, sessionId, context) => {
      // Revert on error
      queryClient.setQueryData(['practiceSessions'], context.previousSessions);
    },
    onSettled: () => {
      // Always refetch after error or success
      queryClient.invalidateQueries(['practiceSessions']);
    }
  });
}
```

```jsx
// components/PracticeSessionManager.jsx - Using React Query
import React from 'react';
import {
  usePracticeSessions,
  useCreatePracticeSession,
  useDeletePracticeSession
} from '../hooks/usePracticeSessions';

function PracticeSessionManager({ userId }) {
  const {
    data: sessions = [],
    isLoading,
    error,
    refetch
  } = usePracticeSessions(userId);
  
  const createSessionMutation = useCreatePracticeSession();
  const deleteSessionMutation = useDeletePracticeSession();

  const handleCreateSession = async (sessionData) => {
    try {
      await createSessionMutation.mutateAsync({
        ...sessionData,
        userId
      });
    } catch (error) {
      console.error('Failed to create session:', error);
    }
  };

  const handleDeleteSession = async (sessionId) => {
    if (window.confirm('Delete this session?')) {
      try {
        await deleteSessionMutation.mutateAsync(sessionId);
      } catch (error) {
        console.error('Failed to delete session:', error);
      }
    }
  };

  if (isLoading) return <div>Loading sessions...</div>;
  
  if (error) {
    return (
      <div className="error">
        <p>Failed to load sessions: {error.message}</p>
        <button onClick={() => refetch()}>Try Again</button>
      </div>
    );
  }

  return (
    <div className="practice-session-manager">
      <div className="header">
        <h2>Practice Sessions</h2>
        <button
          onClick={() => handleCreateSession({
            piece: 'New Practice',
            date: new Date().toISOString()
          })}
          disabled={createSessionMutation.isLoading}
        >
          {createSessionMutation.isLoading ? 'Creating...' : 'New Session'}
        </button>
      </div>

      <div className="sessions">
        {sessions.map(session => (
          <div key={session.id} className="session-card">
            <h3>{session.piece}</h3>
            <p>{new Date(session.date).toLocaleDateString()}</p>
            <button
              onClick={() => handleDeleteSession(session.id)}
              disabled={deleteSessionMutation.isLoading}
            >
              {deleteSessionMutation.isLoading ? 'Deleting...' : 'Delete'}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
```

:::

React Query handles all the complexity of server state management: caching, background refetching, optimistic updates, error handling, and more.

## State management patterns and best practices

Let me share some patterns I've learned from building and maintaining React applications over the years.

### The compound state pattern {.unnumbered .unlisted}

When you have state that logically belongs together, keep it together:

::: example

```jsx
// [BAD] Scattered related state
const [isLoading, setIsLoading] = useState(false);
const [error, setError] = useState(null);
const [data, setData] = useState([]);
const [page, setPage] = useState(1);
const [hasMore, setHasMore] = useState(true);

// [GOOD] Compound state
const [listState, setListState] = useState({
  data: [],
  isLoading: false,
  error: null,
  pagination: {
    page: 1,
    hasMore: true
  }
});

// Helper function for updates
const updateListState = (updates) => {
  setListState(prev => ({
    ...prev,
    ...updates
  }));
};
```

:::

### State normalization {.unnumbered .unlisted}

For complex nested data, normalize your state structure:

::: example

```jsx
// [BAD] Nested, hard to update
const [musicLibrary, setMusicLibrary] = useState({
  composers: [
    {
      id: '1',
      name: 'Beethoven',
      pieces: [
        { id: 'p1', title: 'Moonlight Sonata', difficulty: 'Advanced' },
        { id: 'p2', title: 'Fur Elise', difficulty: 'Intermediate' }
      ]
    }
  ]
});

// [GOOD] Normalized, easy to update
const [musicLibrary, setMusicLibrary] = useState({
  composers: {
    '1': { id: '1', name: 'Beethoven', pieceIds: ['p1', 'p2'] }
  },
  pieces: {
    'p1': { id: 'p1', title: 'Moonlight Sonata', difficulty: 'Advanced', composerId: '1' },
    'p2': { id: 'p2', title: 'Fur Elise', difficulty: 'Intermediate', composerId: '1' }
  }
});
```

:::

### State machines for complex flows {.unnumbered .unlisted}

For complex state transitions, consider using a state machine pattern:

::: example

```jsx
// PracticeSessionStateMachine.jsx
import { useState, useCallback } from 'react';

const PRACTICE_STATES = {
  IDLE: 'idle',
  PREPARING: 'preparing',
  PRACTICING: 'practicing',
  PAUSED: 'paused',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled'
};

const PRACTICE_ACTIONS = {
  START_PREPARATION: 'startPreparation',
  BEGIN_PRACTICE: 'beginPractice',
  PAUSE: 'pause',
  RESUME: 'resume',
  COMPLETE: 'complete',
  CANCEL: 'cancel',
  RESET: 'reset'
};

function practiceSessionReducer(state, action) {
  switch (state.status) {
    case PRACTICE_STATES.IDLE:
      if (action.type === PRACTICE_ACTIONS.START_PREPARATION) {
        return {
          ...state,
          status: PRACTICE_STATES.PREPARING,
          piece: action.payload.piece,
          startTime: null,
          duration: 0
        };
      }
      break;
      
    case PRACTICE_STATES.PREPARING:
      if (action.type === PRACTICE_ACTIONS.BEGIN_PRACTICE) {
        return {
          ...state,
          status: PRACTICE_STATES.PRACTICING,
          startTime: new Date()
        };
      }
      if (action.type === PRACTICE_ACTIONS.CANCEL) {
        return {
          ...state,
          status: PRACTICE_STATES.CANCELLED
        };
      }
      break;
      
    case PRACTICE_STATES.PRACTICING:
      if (action.type === PRACTICE_ACTIONS.PAUSE) {
        return {
          ...state,
          status: PRACTICE_STATES.PAUSED,
          duration: state.duration + (new Date() - state.startTime)
        };
      }
      if (action.type === PRACTICE_ACTIONS.COMPLETE) {
        return {
          ...state,
          status: PRACTICE_STATES.COMPLETED,
          duration: state.duration + (new Date() - state.startTime),
          endTime: new Date()
        };
      }
      break;
      
    case PRACTICE_STATES.PAUSED:
      if (action.type === PRACTICE_ACTIONS.RESUME) {
        return {
          ...state,
          status: PRACTICE_STATES.PRACTICING,
          startTime: new Date()
        };
      }
      if (action.type === PRACTICE_ACTIONS.COMPLETE) {
        return {
          ...state,
          status: PRACTICE_STATES.COMPLETED,
          endTime: new Date()
        };
      }
      break;
  }
  
  // Reset action available from any state
  if (action.type === PRACTICE_ACTIONS.RESET) {
    return {
      status: PRACTICE_STATES.IDLE,
      piece: null,
      startTime: null,
      duration: 0,
      endTime: null
    };
  }
  
  return state;
}

export function usePracticeSessionState() {
  const [state, dispatch] = useReducer(practiceSessionReducer, {
    status: PRACTICE_STATES.IDLE,
    piece: null,
    startTime: null,
    duration: 0,
    endTime: null
  });

  const actions = {
    startPreparation: useCallback((piece) => {
      dispatch({ type: PRACTICE_ACTIONS.START_PREPARATION, payload: { piece } });
    }, []),
    
    beginPractice: useCallback(() => {
      dispatch({ type: PRACTICE_ACTIONS.BEGIN_PRACTICE });
    }, []),
    
    pause: useCallback(() => {
      dispatch({ type: PRACTICE_ACTIONS.PAUSE });
    }, []),
    
    resume: useCallback(() => {
      dispatch({ type: PRACTICE_ACTIONS.RESUME });
    }, []),
    
    complete: useCallback(() => {
      dispatch({ type: PRACTICE_ACTIONS.COMPLETE });
    }, []),
    
    cancel: useCallback(() => {
      dispatch({ type: PRACTICE_ACTIONS.CANCEL });
    }, []),
    
    reset: useCallback(() => {
      dispatch({ type: PRACTICE_ACTIONS.RESET });
    }, [])
  };

  // Derived state
  const canStart = state.status === PRACTICE_STATES.IDLE;
  const canBegin = state.status === PRACTICE_STATES.PREPARING;
  const canPause = state.status === PRACTICE_STATES.PRACTICING;
  const canResume = state.status === PRACTICE_STATES.PAUSED;
  const canComplete = [PRACTICE_STATES.PRACTICING, PRACTICE_STATES.PAUSED].includes(state.status);
  const isActive = [PRACTICE_STATES.PRACTICING, PRACTICE_STATES.PAUSED].includes(state.status);

  return {
    state,
    actions,
    // Convenience flags
    canStart,
    canBegin,
    canPause,
    canResume,
    canComplete,
    isActive
  };
}
```

:::

This state machine pattern prevents impossible states and makes the component logic much clearer.

### Performance optimization patterns {.unnumbered .unlisted}::: example

```jsx
// Selector optimization with useMemo
function useOptimizedSessionList(sessions, filter, sortBy) {
  return useMemo(() => {
    let filtered = sessions;
    
    if (filter === 'recent') {
      const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      filtered = sessions.filter(s => new Date(s.date) > weekAgo);
    }
    
    return filtered.sort((a, b) => {
      switch (sortBy) {
        case 'duration':
          return b.duration - a.duration;
        case 'piece':
          return a.piece.localeCompare(b.piece);
        default:
          return new Date(b.date) - new Date(a.date);
      }
    });
  }, [sessions, filter, sortBy]);
}

// Context splitting to prevent unnecessary re-renders
const UserDataContext = createContext();
const UserActionsContext = createContext();

export function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  
  const actions = useMemo(() => ({
    updateUser: (updates) => setUser(prev => ({ ...prev, ...updates })),
    logout: () => setUser(null)
  }), []);
  
  return (
    <UserDataContext.Provider value={user}>
      <UserActionsContext.Provider value={actions}>
        {children}
      </UserActionsContext.Provider>
    </UserDataContext.Provider>
  );
}

// Components only re-render when their specific context changes
export const useUserData = () => useContext(UserDataContext);
export const useUserActions = () => useContext(UserActionsContext);
```

:::

## Migration strategies

One of the most common questions I get is: "How do I migrate from simple state to complex state management?" The key is to do it gradually.

### From useState to useReducer {.unnumbered .unlisted}::: example

```jsx
// Step 1: Identify related state
const [user, setUser] = useState(null);
const [isLoading, setIsLoading] = useState(false);
const [error, setError] = useState(null);

// Step 2: Group into reducer
const initialState = { user: null, isLoading: false, error: null };

function userReducer(state, action) {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, isLoading: true, error: null };
    case 'FETCH_SUCCESS':
      return { ...state, user: action.payload, isLoading: false };
    case 'FETCH_ERROR':
      return { ...state, error: action.payload, isLoading: false };
    default:
      return state;
  }
}

// Step 3: Replace useState calls
const [state, dispatch] = useReducer(userReducer, initialState);
```

:::

### From prop drilling to Context {.unnumbered .unlisted}::: example

```jsx
// Before: Prop drilling
function App() {
  const [user, setUser] = useState(null);
  return <Layout user={user} setUser={setUser} />;
}

function Layout({ user, setUser }) {
  return <Sidebar user={user} setUser={setUser} />;
}

function Sidebar({ user, setUser }) {
  return <UserMenu user={user} setUser={setUser} />;
}

// After: Context
const UserContext = createContext();

function App() {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Layout />
    </UserContext.Provider>
  );
}

function Layout() {
  return <Sidebar />;
}

function Sidebar() {
  return <UserMenu />;
}

function UserMenu() {
  const { user, setUser } = useContext(UserContext);
  // Use user and setUser directly
}
```

:::

### From Context to external state management {.unnumbered .unlisted}

When Context becomes unwieldy (causing too many re-renders, getting too complex), migrate gradually:

::: example

```jsx
// Step 1: Extract logic from Context to custom hooks
function useUserLogic() {
  const [user, setUser] = useState(null);
  
  const login = useCallback(async (credentials) => {
    // login logic
  }, []);
  
  return { user, login };
}

// Step 2: Replace hook implementation with external store
function useUserLogic() {
  // Now using Zustand instead of useState
  return useUserStore();
}

// Components don't need to change!
```

:::

## Chapter summary

State management in React doesn't have to be overwhelming if you approach it systematically. The key insight is that state management is a spectrum, not a binary choice. Start simple and add complexity only when you need it.

### Key principles for effective state management {.unnumbered .unlisted}**Start with local state**: Use `useState` for component-specific state. It's simple, predictable, and covers most cases.

**Lift state up when needed**: When multiple components need the same state, lift it to their common parent.

**Use useReducer for complex state logic**: When you have multiple related pieces of state that change together, `useReducer` provides better organization.

**Reach for Context sparingly**: Context is great for truly global concerns (auth, theme) but can cause performance issues if overused.

**Choose external libraries based on specific needs**: Redux for complex applications with time-travel debugging needs, Zustand for simple global state, React Query for server state.

**Separate concerns**: Keep server state (React Query) separate from client state (Redux/Zustand). They have different characteristics and needs.

### Migration strategy {.unnumbered .unlisted}

Don't try to implement the perfect state management solution from day one. Instead:

1. Start with `useState` and `useEffect`
2. Refactor to `useReducer` when state logic gets complex
3. Add Context when prop drilling becomes painful
4. Introduce external libraries when Context causes performance issues or you need advanced features
5. Consider React Query early for server state management

Remember, the best state management solution is the simplest one that meets your current needs and can grow with your application. Don't over-engineer, but also don't be afraid to refactor when you outgrow your current approach.

The goal isn't to use the most sophisticated state management library-it's to make your application predictable, maintainable, and performant. Start simple, be intentional about when you add complexity, and always prioritize the developer experience for your team.
