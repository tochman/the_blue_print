# Testing React components

Testing React components requires a pragmatic approach that balances comprehensive coverage with practical development workflows. While testing represents a crucial aspect of professional React development, the approach to testing should be tailored to project requirements, team capabilities, and long-term maintenance considerations.

Effective React component testing provides confidence in refactoring, serves as living documentation, and catches regressions during development. However, testing strategies should be implemented thoughtfully, focusing on valuable test coverage rather than achieving arbitrary metrics or following rigid methodologies without consideration for project context.

This chapter provides practical testing strategies that integrate seamlessly into real development workflows. You'll learn to test components, hooks, and providers effectively while building sustainable testing practices that enhance rather than impede development velocity. The focus is on creating valuable, maintainable tests that provide genuine confidence in application behavior.

::: important
**Comprehensive Testing Resources**

For detailed end-to-end testing strategies and comprehensive testing philosophies, "The Green Line: A Journey Into Automated Testing" provides holistic testing perspectives, including advanced e2e testing techniques that complement the component-focused testing covered in this chapter.
:::

::: tip
**Testing Learning Objectives**

- Understand the strategic value of React component testing
- Implement practical testing strategies for real development workflows
- Test components, hooks, and providers effectively and efficiently
- Navigate the testing tool landscape: Jest, React Testing Library, Cypress, and more
- Balance unit tests, integration tests, and end-to-end tests appropriately
- Configure testing in CI/CD pipelines (detailed further in Chapter 9)
- Apply real-world testing patterns that provide long-term value and maintainability
:::

## Strategic approach to React component testing

Before exploring testing implementation, understanding the strategic purpose and appropriate application of testing proves essential. Testing serves as a tool to solve specific development problems rather than a universal requirement, making it crucial to understand when and how testing provides value.

## The strategic value of component testing

**Refactoring Confidence**: Tests verify that external behavior remains consistent when component internal implementation changes. This proves invaluable during performance optimization or component logic restructuring.

**Behavioral Documentation**: Well-written tests serve as living documentation of component behavior expectations. They provide more reliable documentation than written specifications because they're automatically verified.

**Regression Prevention**: As applications scale, manual verification of all component functionality becomes impossible. Tests automatically catch when changes inadvertently break existing functionality.

**Debugging Acceleration**: Test failures often point directly to problems, significantly faster than reproducing bugs through manual application interaction.

**Team Communication**: Tests clarify behavioral expectations for other developers and future maintainers, preserving important component contracts.

## When testing may not provide value

**Highly Experimental Features**: Rapid prototyping scenarios where code is frequently discarded may not benefit from comprehensive testing investment.

**Simple Presentational Components**: Components that merely accept props and render them without logic may not require extensive testing.

**Rapidly Changing Requirements**: When business requirements shift frequently, test maintenance may consume more time than feature development.

**Short-term Projects**: Projects with limited lifespans and minimal long-term maintenance may not justify testing investment.

The key lies in applying testing strategically based on project context rather than following rigid testing dogma.

## Testing strategy architecture for React applications

Effective testing strategies follow the testing pyramid concept:

**Unit tests**: Test individual components and functions in isolation. These are fast, easy to write, and great for testing component logic and edge cases.

**Integration tests**: Test how multiple components work together. These catch issues with component communication and data flow.

**End-to-end tests**: Test complete user workflows in a real browser. These catch issues with the entire application stack but are slower and more brittle.

For React applications, I generally recommend:

- Lots of unit tests for complex components and custom hooks
- Some integration tests for critical user flows
- A few e2e tests for your most important features

The exact ratio depends on your application, but this gives you a starting point.

## Setting up your testing environment

Now that we've talked about *when* and *why* to test, let's get practical about *how*. I'll show you the tools you need and how to set them up so you can start testing right away.

Most React projects today use Jest as the testing framework and React Testing Library for component testing utilities. The good news is that if you're using Create React App or Vite, much of this setup is already done for you. But even if you're starting from scratch, getting a basic testing environment running is simpler than you might think.

### The testing tools you'll actually use {.unnumbered .unlisted}

Let me introduce you to the essential tools in the React testing ecosystem. Don't worry about memorizing everything--we'll see these in action throughout the chapter:

**Jest**: This is your testing foundation. Jest runs your tests, provides assertion methods (like `expect()`), and handles mocking. It's fast, has excellent error messages, and works seamlessly with React.

**React Testing Library**: This is where the magic happens for component testing. It provides utilities for testing React components in a way that closely mirrors how users actually interact with your app. The key insight: instead of testing implementation details, you test behavior.

**@testing-library/jest-dom**: Think of this as Jest's React-savvy cousin. It adds custom matchers like `toBeInTheDocument()` and `toHaveValue()` that make your test assertions much more readable.

**@testing-library/user-event**: This simulates real user interactions--clicking, typing, hovering--in a way that closely matches what happens in a real browser.

::: example

```bash
# Install testing dependencies
npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event

# If you're not using Create React App, you might also need:
npm install --save-dev jest jest-environment-jsdom
```

:::

### Getting your test setup working {.unnumbered .unlisted}

Here's a basic setup that will work for most React testing scenarios. Don't worry if some of this looks unfamiliar--we'll explain each piece as we use it:

::: example

```javascript
// src/setupTests.js
import '@testing-library/jest-dom';

// Global test configuration
beforeEach(() => {
  // Clear any mocks between tests to avoid interference
  jest.clearAllMocks();
});

// Mock common browser APIs that Jest doesn't provide by default
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock localStorage since it's not available in the test environment
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
};
Object.defineProperty(window, 'localStorage', {
  value: localStorageMock
});
```

:::

This setup file runs before each test and provides the basic environment your React components need. Think of it as setting the stage before each performance.

## Testing React components: the fundamentals

Now we're ready to write our first tests. But before we jump into code, let me share some fundamental patterns that will make your tests clearer, more maintainable, and easier to debug. These aren't rigid rules--think of them as helpful guidelines that will serve you well as you develop your testing style.

::: important
**Understanding mocks, stubs, and spies**

You'll see these terms used throughout testing, and while they're similar, they serve different purposes:

**Mocks** are fake implementations of functions or modules that you control completely. They replace real dependencies and let you verify how your code interacts with them. In Jest, you create mocks with `jest.fn()` or `jest.mock()`.

```javascript
const mockOnSave = jest.fn(); // Creates a mock function
jest.mock('./api/userAPI'); // Mocks an entire module
```

**Stubs** are simplified implementations that return predetermined values. They're useful when you need a function to behave in a specific way for your test. Cypress uses `cy.stub()` for this.

```javascript
const onComplete = cy.stub().returns(true); // Always returns true
```

**Spies** watch real functions and record how they're called, but still execute the original function. They're useful when you want to verify function calls without changing behavior.

```javascript
const consoleSpy = jest.spyOn(console, 'error'); // Watches console.error
```

**In practice:**
 You'll mostly use mocks in React testing--they're simpler and give you complete control over dependencies. Don't worry too much about the terminology; focus on the concept of replacing real dependencies with predictable, testable ones.
:::

::: tip
**The anatomy of a test: Understanding the building blocks**

When you first look at a test file, you'll see several keywords that structure how tests are organized and run. Let me break down each piece so you understand what's happening:

**`describe()` - Grouping related tests**
Think of `describe` as a way to organize your tests into logical groups. It's like creating folders for different aspects of your component:

```javascript
describe('PracticeTimer', () => {
  // All tests for the PracticeTimer component go here
  
  describe('when timer is stopped', () => {
    // Tests for stopped state
  });
  
  describe('when timer is running', () => {
    // Tests for running state
  });
});
```

**`context()` - Alternative to describe for clarity**
`context` is just an alias for `describe`, but many teams use it to make test organization more readable:

```javascript
describe('PracticeTimer', () => {
  context('when user clicks start button', () => {
    // Tests for this specific scenario
  });
  
  context('when initial time is provided', () => {
    // Tests for this different scenario
  });
});
```

**`beforeEach()` - Setup that runs before every test**
Use `beforeEach` for setup code that every test in that group needs:

```javascript
describe('PracticeTimer', () => {
  let mockOnComplete;
  
  beforeEach(() => {
    // This runs before EACH test in this describe block
    mockOnComplete = jest.fn();
    jest.clearAllMocks();
  });
  
  it('is expected to call onComplete when finished', () => {
    // mockOnComplete is fresh and clean for this test
  });
});
```

**`before()` - Setup that runs once before all tests**
Use `before` (or `beforeAll` in Jest) for expensive setup that only needs to happen once:

```javascript
describe('PracticeTimer', () => {
  beforeAll(() => {
    // This runs ONCE before all tests in this group
    jest.useFakeTimers();
  });
  
  afterAll(() => {
    // Clean up after all tests
    jest.useRealTimers();
  });
});
```

**`it()` - Individual test cases**
Each `it()` block is a single test. The description should complete the sentence "it is expected to...":

```javascript
describe('PracticeTimer', () => {
  it('is expected to display initial time correctly', () => {
    // Test implementation
  });
  
  it('is expected to start counting when start button is clicked', () => {
    // Test implementation
  });
});
```

**`expect()` - Making assertions**
`expect()` is how you check if something is true. It starts an assertion chain:

```javascript
it('is expected to display user name', () => {
  render(<UserProfile name="John" />);
  
  // expect() starts the assertion
  expect(screen.getByText('John')).toBeInTheDocument();
});
```

**Common matchers you'll use every day:**


```javascript
// Text and content
expect(screen.getByText('Hello')).toBeInTheDocument();
expect(screen.getByLabelText('Email')).toHaveValue('test@example.com');
expect(screen.getByRole('button')).toHaveTextContent('Submit');

// Function calls
expect(mockFunction).toHaveBeenCalled();
expect(mockFunction).toHaveBeenCalledWith('expected', 'arguments');
expect(mockFunction).toHaveBeenCalledTimes(2);

// Element states
expect(screen.getByRole('button')).toBeDisabled();
expect(screen.getByTestId('loading')).toBeVisible();
expect(screen.queryByText('Error')).not.toBeInTheDocument();

// Form elements
expect(screen.getByLabelText('Email')).toHaveValue('user@example.com');
expect(screen.getByRole('checkbox')).toBeChecked();
expect(screen.getByDisplayValue('Search term')).toBeFocused();

// Numbers and values
expect(result.current.count).toBe(5);
expect(apiResponse.data).toEqual({ id: 1, name: 'Test' });
expect(userList).toHaveLength(3);

// Async operations
await waitFor(() => {
  expect(screen.getByText('Data loaded')).toBeInTheDocument();
});
```

**Putting it all together - A complete test structure:**


```javascript
describe('LoginForm', () => {
  let mockOnLogin;
  
  beforeEach(() => {
    mockOnLogin = jest.fn();
  });

  context('when form is submitted with valid data', () => {
    beforeEach(() => {
      render(<LoginForm onLogin={mockOnLogin} />);
    });

    it('is expected to call onLogin with email and password', async () => {
      const user = userEvent.setup();
      
      await user.type(screen.getByLabelText('Email'), 'test@example.com');
      await user.type(screen.getByLabelText('Password'), 'password123');
      await user.click(screen.getByRole('button', { name: 'Log In' }));
      
      expect(mockOnLogin).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });

    it('is expected to show loading state during submission', async () => {
      const user = userEvent.setup();
      
      await user.type(screen.getByLabelText('Email'), 'test@example.com');
      await user.type(screen.getByLabelText('Password'), 'password123');
      await user.click(screen.getByRole('button', { name: 'Log In' }));
      
      expect(screen.getByText('Logging in...')).toBeInTheDocument();
    });
  });

  context('when form is submitted with invalid data', () => {
    it('is expected to show validation errors', async () => {
      const user = userEvent.setup();
      render(<LoginForm onLogin={mockOnLogin} />);
      
      await user.click(screen.getByRole('button', { name: 'Log In' }));
      
      expect(screen.getByText('Email is required')).toBeInTheDocument();
      expect(mockOnLogin).not.toHaveBeenCalled();
    });
  });
});
```

:::

### The AAA pattern: A helpful testing structure {.unnumbered .unlisted}

One pattern I find incredibly helpful for organizing tests is the AAA pattern. It's not the only way to structure tests, but it's one that I use consistently because it gives me a clear mental framework:

**Arrange**: Set up your test data, mocks, and render your component
**Act**: Perform the action you want to test (click a button, type in a field, etc.)
**Assert**: Check that the expected outcome occurred

This pattern gives you a clear mental framework for writing tests and makes them easier to read and debug.

::: example

```javascript
describe('UserProfile', () => {
  it('is expected to save user changes when save button is clicked', async () => {
    // ARRANGE
    const mockUser = { name: 'John Doe', email: 'john@example.com' };
    const mockOnSave = jest.fn();
    const user = userEvent.setup();
    
    render(<UserProfile user={mockUser} onSave={mockOnSave} />);

    // ACT
    await user.click(screen.getByText('Edit'));
    await user.clear(screen.getByLabelText('Name'));
    await user.type(screen.getByLabelText('Name'), 'Jane Doe');
    await user.click(screen.getByText('Save'));

    // ASSERT
    expect(mockOnSave).toHaveBeenCalledWith({
      ...mockUser,
      name: 'Jane Doe'
    });
  });
});
```

:::

You'll notice this pattern throughout all the examples in this chapter--it helps make tests more readable and easier to understand. The AAA pattern works especially well with the "is expected to" naming convention because it forces you to think about:

- **What setup do I need?** (Arrange)
- **What action am I testing?** (Act)  
- **What should happen as a result?** (Assert)

When you combine this with the testing building blocks we just learned (describe, context, beforeEach, it, expect), you get tests that are both well-structured and easy to understand.

### Writing better test names {.unnumbered .unlisted}

I recommend using "is expected to" format for all your test descriptions. This forces you to think about the expected behavior from the user's perspective and makes failing tests easier to understand.

::: example

```javascript
// [BAD] Unclear test names
it('renders correctly');
it('handles click');
it('validates form');

// [GOOD] Clear behavioral descriptions
it('is expected to display user name and email');
it('is expected to call onDelete when delete button is clicked');
it('is expected to show error message when email is invalid');
```

:::

### Keep your tests focused {.unnumbered .unlisted}

While not a hard rule, try to limit the number of assertions in each test. This makes it easier to understand what broke when a test fails. If you need to test multiple things, consider separating them into different tests.

::: example

```javascript
// [BAD] Multiple concerns in one test
it('is expected to handle form submission', async () => {
  const user = userEvent.setup();
  render(<ContactForm />);
  
  await user.type(screen.getByLabelText('Email'), 'test@example.com');
  await user.type(screen.getByLabelText('Message'), 'Hello world');
  await user.click(screen.getByText('Send'));
  
  expect(screen.getByText('Sending...')).toBeInTheDocument();
  expect(mockSendEmail).toHaveBeenCalledWith({
    email: 'test@example.com',
    message: 'Hello world'
  });
  expect(screen.getByText('Message sent!')).toBeInTheDocument();
});

// [GOOD] Separated concerns
describe('ContactForm', () => {
  beforeEach(() => {
    // ARRANGE - common setup
    const user = userEvent.setup();
    render(<ContactForm />);
  });

  it('is expected to show loading state when submitting', async () => {
    // ACT
    await user.type(screen.getByLabelText('Email'), 'test@example.com');
    await user.type(screen.getByLabelText('Message'), 'Hello');
    await user.click(screen.getByText('Send'));

    // ASSERT
    expect(screen.getByText('Sending...')).toBeInTheDocument();
  });

  it('is expected to call sendEmail with form data', async () => {
    // ACT
    await user.type(screen.getByLabelText('Email'), 'test@example.com');
    await user.type(screen.getByLabelText('Message'), 'Hello');
    await user.click(screen.getByText('Send'));

    // ASSERT
    expect(mockSendEmail).toHaveBeenCalledWith({
      email: 'test@example.com',
      message: 'Hello'
    });
  });
});
```

:::

Notice how the second approach makes it immediately clear which specific behavior failed if a test breaks.

### Your first component tests {.unnumbered .unlisted}

Let's put these concepts into practice. We'll start with presentational components because they're the easiest to test--they take props and render UI without complex logic. This makes them perfect for learning the testing fundamentals without getting overwhelmed.

Here's a typical React component you might find in a music practice app:

::: example

```jsx
// PracticeSessionCard.jsx
function PracticeSessionCard({ session, onStart, onDelete }) {
  const formattedDate = new Date(session.date).toLocaleDateString();
  const formattedDuration = `${Math.floor(session.duration / 60)}:${(session.duration % 60).toString().padStart(2, '0')}`;

  return (
    <div className="practice-session-card" data-testid="session-card">
      <h3>{session.piece}</h3>
      <p className="composer">{session.composer}</p>
      <p className="date">{formattedDate}</p>
      <p className="duration">{formattedDuration}</p>
      
      <div className="card-actions">
        <button onClick={() => onStart(session.id)}>Start Practice</button>
        <button onClick={() => onDelete(session.id)} className="delete-btn">
          Delete
        </button>
      </div>
    </div>
  );
}
```

This component is perfect for testing because it:

- Takes clear inputs (props)
- Produces visible outputs (rendered content)
- Has user interactions (button clicks)
- Contains some logic (date and duration formatting)

Now let's see how to test it step by step:

```javascript
// PracticeSessionCard.test.js
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import PracticeSessionCard from './PracticeSessionCard';

describe('PracticeSessionCard', () => {
  // First, let's set up our test data
  const mockSession = {
    id: '1',
    piece: 'Moonlight Sonata',
    composer: 'Beethoven',
    date: '2023-10-15T10:30:00Z',
    duration: 1800 // 30 minutes in seconds
  };

  // Create mock functions to track interactions
  const mockOnStart = jest.fn();
  const mockOnDelete = jest.fn();

  beforeEach(() => {
    // Clean slate for each test - clear any previous calls
    mockOnStart.mockClear();
    mockOnDelete.mockClear();
  });

  // Test 1: Does the component display the information correctly?
  it('is expected to render session information correctly', () => {
    // ARRANGE: Render the component with our test data
    render(
      <PracticeSessionCard
        session={mockSession}
        onStart={mockOnStart}
        onDelete={mockOnDelete}
      />
    );

    // ASSERT: Check that the expected content appears on screen
    expect(screen.getByText('Moonlight Sonata')).toBeInTheDocument();
    expect(screen.getByText('Beethoven')).toBeInTheDocument();
    expect(screen.getByText('10/15/2023')).toBeInTheDocument();
    expect(screen.getByText('30:00')).toBeInTheDocument();
  });

  // Test 2: Does clicking the start button work?
  it('is expected to call onStart when start button is clicked', async () => {
    // ARRANGE: Set up user interaction simulation and render component
    const user = userEvent.setup();
    render(
      <PracticeSessionCard
        session={mockSession}
        onStart={mockOnStart}
        onDelete={mockOnDelete}
      />
    );

    // ACT: Simulate a user clicking the start button
    await user.click(screen.getByText('Start Practice'));
    
    // ASSERT: Verify the callback was called with the right data
    expect(mockOnStart).toHaveBeenCalledWith('1');
    expect(mockOnStart).toHaveBeenCalledTimes(1);
  });

  // Test 3: Does clicking the delete button work?
  it('is expected to call onDelete when delete button is clicked', async () => {
    // ARRANGE
    const user = userEvent.setup();
    render(
      <PracticeSessionCard
        session={mockSession}
        onStart={mockOnStart}
        onDelete={mockOnDelete}
      />
    );

    // ACT
    await user.click(screen.getByText('Delete'));
    
    // ASSERT
    expect(mockOnDelete).toHaveBeenCalledWith('1');
    expect(mockOnDelete).toHaveBeenCalledTimes(1);
  });

  // Test 4: Does the component handle different data correctly?
  it('is expected to format duration correctly for different time values', () => {
    // ARRANGE: Create test data with a different duration
    const sessionWithDifferentDuration = {
      ...mockSession,
      duration: 3665 // 1 hour, 1 minute, 5 seconds
    };

    render(
      <PracticeSessionCard
        session={sessionWithDifferentDuration}
        onStart={mockOnStart}
        onDelete={mockOnDelete}
      />
    );

    // ASSERT: Check that the duration formatting logic works
    expect(screen.getByText('61:05')).toBeInTheDocument();
  });
});
```

Let's break down what we just learned from this test:

**1. We test what users see and do**: Instead of testing internal state or implementation details, we test the rendered output and user interactions. If a user can see "Moonlight Sonata" on the screen, that's what we test for.

**2. We use descriptive test data**: Our `mockSession` object contains realistic data that helps us understand what the test is doing. This makes tests easier to read and debug.

**3. We test different scenarios**: We don't just test the happy path. We test edge cases (like different duration formats) to make sure our component handles various inputs correctly.

**4. We isolate each test**: Each test focuses on one specific behavior. This makes it immediately clear what broke when a test fails.

**5. We clean up between tests**: The `beforeEach` hook ensures each test starts with a clean slate.

### When components have state {.unnumbered .unlisted}

Components with internal state are a bit more complex to test, but the approach is similar--focus on the behavior users can observe:

::: example

```jsx
// PracticeTimer.jsx
import { useState, useEffect, useRef } from 'react';

function PracticeTimer({ onComplete, initialTime = 0 }) {
  const [time, setTime] = useState(initialTime);
  const [isRunning, setIsRunning] = useState(false);
  const intervalRef = useRef(null);

  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(() => {
        setTime(prevTime => prevTime + 1);
      }, 1000);
    } else {
      clearInterval(intervalRef.current);
    }

    return () => clearInterval(intervalRef.current);
  }, [isRunning]);

  const handleStart = () => setIsRunning(true);
  const handlePause = () => setIsRunning(false);
  
  const handleReset = () => {
    setIsRunning(false);
    setTime(0);
  };

  const handleComplete = () => {
    setIsRunning(false);
    onComplete(time);
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="practice-timer">
      <div className="time-display">{formatTime(time)}</div>
      
      <div className="timer-controls">
        {!isRunning ? (
          <button onClick={handleStart}>Start</button>
        ) : (
          <button onClick={handlePause}>Pause</button>
        )}
        
        <button onClick={handleReset}>Reset</button>
        <button onClick={handleComplete} disabled={time === 0}>
          Complete Session
        </button>
      </div>
    </div>
  );
}
```

```javascript
// PracticeTimer.test.js
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import PracticeTimer from './PracticeTimer';

// Mock timers for testing time-dependent functionality
jest.useFakeTimers();

describe('PracticeTimer', () => {
  const mockOnComplete = jest.fn();

  beforeEach(() => {
    mockOnComplete.mockClear();
    jest.clearAllTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('is expected to display initial time correctly', () => {
    render(<PracticeTimer onComplete={mockOnComplete} initialTime={90} />);
    
    expect(screen.getByText('1:30')).toBeInTheDocument();
  });

  it('is expected to start and pause the timer', async () => {
    const user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime });
    
    render(<PracticeTimer onComplete={mockOnComplete} />);

    // Initially stopped
    expect(screen.getByText('0:00')).toBeInTheDocument();
    expect(screen.getByText('Start')).toBeInTheDocument();

    // Start the timer
    await user.click(screen.getByText('Start'));
    expect(screen.getByText('Pause')).toBeInTheDocument();

    // Advance time and check if timer updates
    jest.advanceTimersByTime(3000);
    
    await waitFor(() => {
      expect(screen.getByText('0:03')).toBeInTheDocument();
    });

    // Pause the timer
    await user.click(screen.getByText('Pause'));
    expect(screen.getByText('Start')).toBeInTheDocument();

    // Time should not advance when paused
    jest.advanceTimersByTime(2000);
    expect(screen.getByText('0:03')).toBeInTheDocument();
  });

  it('is expected to reset the timer', async () => {
    const user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime });
    
    render(<PracticeTimer onComplete={mockOnComplete} />);

    // Start timer and let it run
    await user.click(screen.getByText('Start'));
    jest.advanceTimersByTime(5000);
    
    await waitFor(() => {
      expect(screen.getByText('0:05')).toBeInTheDocument();
    });

    // Reset should stop the timer and reset to 0
    await user.click(screen.getByText('Reset'));
    
    expect(screen.getByText('0:00')).toBeInTheDocument();
    expect(screen.getByText('Start')).toBeInTheDocument();
  });

  it('is expected to call onComplete with current time', async () => {
    const user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime });
    
    render(<PracticeTimer onComplete={mockOnComplete} />);

    // Start timer and let it run
    await user.click(screen.getByText('Start'));
    jest.advanceTimersByTime(10000);

    await waitFor(() => {
      expect(screen.getByText('0:10')).toBeInTheDocument();
    });

    // Complete session
    await user.click(screen.getByText('Complete Session'));
    
    expect(mockOnComplete).toHaveBeenCalledWith(10);
    expect(screen.getByText('Start')).toBeInTheDocument(); // Should be stopped
  });

  it('is expected to disable complete button when time is 0', () => {
    render(<PracticeTimer onComplete={mockOnComplete} />);
    
    expect(screen.getByText('Complete Session')).toBeDisabled();
  });
});
```

:::

Key testing patterns for stateful components:

- **Mock timers**: Use `jest.useFakeTimers()` to control time-dependent behavior
- **Test state changes**: Verify that user interactions cause the expected state changes
- **Test side effects**: Make sure callbacks are called with the right parameters
- **Test edge cases**: Like disabled states and boundary conditions

## Testing custom hooks

Custom hooks are some of the most important things to test in React applications because they often contain your business logic. The React Testing Library provides a `renderHook` utility specifically for this purpose.

### Starting with simple hooks {.unnumbered .unlisted}

::: example

```jsx
// usePracticeTimer.js
import { useState, useEffect, useRef, useCallback } from 'react';

export function usePracticeTimer(initialTime = 0) {
  const [time, setTime] = useState(initialTime);
  const [isRunning, setIsRunning] = useState(false);
  const intervalRef = useRef(null);

  useEffect(() => {
    if (isRunning) {
      intervalRef.current = setInterval(() => {
        setTime(prevTime => prevTime + 1);
      }, 1000);
    } else {
      clearInterval(intervalRef.current);
    }

    return () => clearInterval(intervalRef.current);
  }, [isRunning]);

  const start = useCallback(() => setIsRunning(true), []);
  const pause = useCallback(() => setIsRunning(false), []);
  
  const reset = useCallback(() => {
    setIsRunning(false);
    setTime(0);
  }, []);

  const handleComplete = useCallback(() => {
    setIsRunning(false);
    onComplete(time);
  }, [onComplete, time]);

  const formatTime = useCallback((seconds = time) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }, [time]);

  return {
    time,
    isRunning,
    start,
    pause,
    reset,
    formatTime
  };
}
```

```javascript
// usePracticeTimer.test.js
import { renderHook, act } from '@testing-library/react';
import { usePracticeTimer } from './usePracticeTimer';

jest.useFakeTimers();

describe('usePracticeTimer', () => {
  beforeEach(() => {
    jest.clearAllTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('is expected to initialize with default values', () => {
    // ARRANGE & ACT
    const { result } = renderHook(() => usePracticeTimer());
    
    // ASSERT
    expect(result.current.time).toBe(0);
    expect(result.current.isRunning).toBe(false);
    expect(result.current.formatTime()).toBe('0:00');
  });

  it('is expected to initialize with custom initial time', () => {
    // ARRANGE & ACT
    const { result } = renderHook(() => usePracticeTimer(90));
    
    // ASSERT
    expect(result.current.time).toBe(90);
    expect(result.current.formatTime()).toBe('1:30');
  });

  it('is expected to start the timer', () => {
    // ARRANGE
    const { result } = renderHook(() => usePracticeTimer());
    
    // ACT
    act(() => {
      result.current.start();
    });
    
    // ASSERT
    expect(result.current.isRunning).toBe(true);
  });

  it('is expected to pause the timer', () => {
    // ARRANGE
    const { result } = renderHook(() => usePracticeTimer());
    act(() => {
      result.current.start();
    });
    
    // ACT
    act(() => {
      result.current.pause();
    });
    
    // ASSERT
    expect(result.current.isRunning).toBe(false);
  });

  it('is expected to increment time when running', () => {
    // ARRANGE
    const { result } = renderHook(() => usePracticeTimer());
    act(() => {
      result.current.start();
    });
    
    // ACT
    act(() => {
      jest.advanceTimersByTime(5000);
    });
    
    // ASSERT
    expect(result.current.time).toBe(5);
  });

  it('is expected to reset timer to initial state', async () => {
    const user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime });
    
    render(<PracticeTimer onComplete={mockOnComplete} />);

    // Start timer and let it run
    await user.click(screen.getByText('Start'));
    jest.advanceTimersByTime(5000);
    
    await waitFor(() => {
      expect(screen.getByText('0:05')).toBeInTheDocument();
    });

    // Reset should stop the timer and reset to 0
    await user.click(screen.getByText('Reset'));
    
    expect(screen.getByText('0:00')).toBeInTheDocument();
    expect(screen.getByText('Start')).toBeInTheDocument();
});

### Testing Custom Hooks: When Components Need Help {.unnumbered .unlisted}

Testing custom hooks requires a different approach since hooks can't be called outside of components. Let's explore testing strategies with our `usePracticeSessions` hook:
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!userId) return;

    let cancelled = false;

    const fetchSessions = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const data = await practiceSessionAPI.getUserSessions(userId);
        
        if (!cancelled) {
          setSessions(data);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    fetchSessions();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  const addSession = async (sessionData) => {
    try {
      const newSession = await practiceSessionAPI.createSession({
        ...sessionData,
        userId
      });
      setSessions(prev => [newSession, ...prev]);
      return newSession;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  const deleteSession = async (sessionId) => {
    try {
      await practiceSessionAPI.deleteSession(sessionId);
      setSessions(prev => prev.filter(session => session.id !== sessionId));
    } catch (err) {
      setError(err.message);
      throw err;
    }
  };

  return {
    sessions,
    loading,
    error,
    addSession,
    deleteSession
  };
}
```

```javascript
// usePracticeSessions.test.js
import { renderHook, act, waitFor } from '@testing-library/react';
import { usePracticeSessions } from './usePracticeSessions';
import { practiceSessionAPI } from '../api/practiceSessionAPI';

// Mock the API module
jest.mock('../api/practiceSessionAPI');

describe('usePracticeSessions', () => {
  const mockSessions = [
    { id: '1', piece: 'Moonlight Sonata', composer: 'Beethoven' },
    { id: '2', piece: 'Fur Elise', composer: 'Beethoven' }
  ];

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('is expected to fetch sessions on mount', async () => {
    practiceSessionAPI.getUserSessions.mockResolvedValue(mockSessions);

    const { result } = renderHook(() => usePracticeSessions('user123'));

    // Initially loading
    expect(result.current.loading).toBe(true);
    expect(result.current.sessions).toEqual([]);
    expect(result.current.error).toBe(null);

    // Wait for fetch to complete
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.sessions).toEqual(mockSessions);
    expect(practiceSessionAPI.getUserSessions).toHaveBeenCalledWith('user123');
  });

  it('is expected to handle fetch errors', async () => {
    const errorMessage = 'Failed to fetch sessions';
    practiceSessionAPI.getUserSessions.mockRejectedValue(new Error(errorMessage));

    const { result } = renderHook(() => usePracticeSessions('user123'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.error).toBe(errorMessage);
    expect(result.current.sessions).toEqual([]);
  });

  it('is expected to add new session', async () => {
    practiceSessionAPI.getUserSessions.mockResolvedValue(mockSessions);
    
    const newSession = { id: '3', piece: 'Clair de Lune', composer: 'Debussy' };
    practiceSessionAPI.createSession.mockResolvedValue(newSession);

    const { result } = renderHook(() => usePracticeSessions('user123'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    await act(async () => {
      await result.current.addSession({ piece: 'Clair de Lune', composer: 'Debussy' });
    });

    expect(result.current.sessions[0]).toEqual(newSession);
    expect(practiceSessionAPI.createSession).toHaveBeenCalledWith({
      piece: 'Clair de Lune',
      composer: 'Debussy',
      userId: 'user123'
    });
  });

  it('is expected to delete session', async () => {
    practiceSessionAPI.getUserSessions.mockResolvedValue(mockSessions);
    practiceSessionAPI.deleteSession.mockResolvedValue();

    const { result } = renderHook(() => usePracticeSessions('user123'));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    await act(async () => {
      await result.current.deleteSession('1');
    });

    expect(result.current.sessions).toHaveLength(1);
    expect(result.current.sessions[0].id).toBe('2');
    expect(practiceSessionAPI.deleteSession).toHaveBeenCalledWith('1');
  });

  it('is expected not to fetch when userId is not provided', () => {
    const { result } = renderHook(() => usePracticeSessions(null));

    expect(result.current.loading).toBe(true);
    expect(practiceSessionAPI.getUserSessions).not.toHaveBeenCalled();
  });
});
```

:::

### Testing providers and context {.unnumbered .unlisted}

Context providers often contain important application state and logic, making them crucial to test. Here's how to approach testing them effectively:

### Testing your context providers {.unnumbered .unlisted}::: example

```jsx
// PracticeSessionProvider.jsx
import React, { createContext, useContext, useReducer, useCallback } from 'react';

const PracticeSessionContext = createContext();

const initialState = {
  currentSession: null,
  isRecording: false,
  sessionHistory: [],
  error: null
};

function sessionReducer(state, action) {
  switch (action.type) {
    case 'START_SESSION':
      return {
        ...state,
        currentSession: action.payload,
        isRecording: true,
        error: null
      };
    
    case 'END_SESSION':
      return {
        ...state,
        currentSession: null,
        isRecording: false,
        sessionHistory: [action.payload, ...state.sessionHistory]
      };
    
    case 'SET_ERROR':
      return {
        ...state,
        error: action.payload,
        isRecording: false
      };
    
    case 'CLEAR_ERROR':
      return {
        ...state,
        error: null
      };
    
    default:
      return state;
  }
}

export function PracticeSessionProvider({ children }) {
  const [state, dispatch] = useReducer(sessionReducer, initialState);

  const startSession = useCallback((sessionData) => {
    try {
      const session = {
        ...sessionData,
        id: Date.now().toString(),
        startTime: new Date().toISOString()
      };
      dispatch({ type: 'START_SESSION', payload: session });
      return session;
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
      throw error;
    }
  }, []);

  const endSession = useCallback(() => {
    if (!state.currentSession) {
      throw new Error('No active session to end');
    }

    const completedSession = {
      ...state.currentSession,
      endTime: new Date().toISOString(),
      duration: Date.now() - new Date(state.currentSession.startTime).getTime()
    };

    dispatch({ type: 'END_SESSION', payload: completedSession });
    return completedSession;
  }, [state.currentSession]);

  const clearError = useCallback(() => {
    dispatch({ type: 'CLEAR_ERROR' });
  }, []);

  const value = {
    ...state,
    startSession,
    endSession,
    clearError
  };

  return (
    <PracticeSessionContext.Provider value={value}>
      {children}
    </PracticeSessionContext.Provider>
  );
}

export function usePracticeSession() {
  const context = useContext(PracticeSessionContext);
  if (!context) {
    throw new Error('usePracticeSession must be used within PracticeSessionProvider');
  }
  return context;
}
```

```javascript
// PracticeSessionProvider.test.js
import React from 'react';
import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { PracticeSessionProvider, usePracticeSession } from './PracticeSessionProvider';

// Test component to interact with the provider
function TestComponent() {
  const {
    currentSession,
    isRecording,
    sessionHistory,
    error,
    startSession,
    endSession,
    clearError
  } = usePracticeSession();

  const handleStartSession = () => {
    startSession({
      piece: 'Test Piece',
      composer: 'Test Composer'
    });
  };

  return (
    <div>
      <div data-testid="current-session">
        {currentSession ? currentSession.piece : 'No session'}
      </div>
      <div data-testid="is-recording">{isRecording ? 'Recording' : 'Not recording'}</div>
      <div data-testid="session-count">{sessionHistory.length}</div>
      <div data-testid="error">{error || 'No error'}</div>
      
      <button onClick={handleStartSession}>Start Session</button>
      <button onClick={endSession}>End Session</button>
      <button onClick={clearError}>Clear Error</button>
    </div>
  );
}

function renderWithProvider(ui) {
  return render(
    <PracticeSessionProvider>
      {ui}
    </PracticeSessionProvider>
  );
}

describe('PracticeSessionProvider', () => {
  it('is expected to provide initial state', () => {
    renderWithProvider(<TestComponent />);

    expect(screen.getByTestId('current-session')).toHaveTextContent('No session');
    expect(screen.getByTestId('is-recording')).toHaveTextContent('Not recording');
    expect(screen.getByTestId('session-count')).toHaveTextContent('0');
    expect(screen.getByTestId('error')).toHaveTextContent('No error');
  });

  it('is expected to start a session', async () => {
    const user = userEvent.setup();
    renderWithProvider(<TestComponent />);

    await user.click(screen.getByText('Start Session'));

    expect(screen.getByTestId('current-session')).toHaveTextContent('Test Piece');
    expect(screen.getByTestId('is-recording')).toHaveTextContent('Recording');
  });

  it('is expected to end a session and add it to history', async () => {
    const user = userEvent.setup();
    renderWithProvider(<TestComponent />);

    // Start a session first
    await user.click(screen.getByText('Start Session'));
    expect(screen.getByTestId('current-session')).toHaveTextContent('Test Piece');

    // End the session
    await user.click(screen.getByText('End Session'));
    expect(screen.getByTestId('current-session')).toHaveTextContent('No session');
    expect(screen.getByTestId('is-recording')).toHaveTextContent('Not recording');
    expect(screen.getByTestId('session-count')).toHaveTextContent('1');
  });

  it('is expected to throw error when usePracticeSession is used outside provider', () => {
    // Suppress console.error for this test
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

    expect(() => {
      render(<TestComponent />);
    }).toThrow('usePracticeSession must be used within PracticeSessionProvider');

    consoleSpy.mockRestore();
  });
});
```

:::

### Testing components that use context {.unnumbered .unlisted}

Sometimes you want to test how a component interacts with context rather than testing the provider in isolation:

::: example

```jsx
// SessionDisplay.jsx
import React from 'react';
import { usePracticeSession } from './PracticeSessionProvider';

function SessionDisplay() {
  const { currentSession, isRecording, startSession, endSession } = usePracticeSession();

  if (!currentSession) {
    return (
      <div>
        <p>No active session</p>
        <button 
          onClick={() => startSession({ piece: 'New Practice', composer: 'Unknown' })}
        >
          Start New Session
        </button>
      </div>
    );
  }

  return (
    <div>
      <h2>Current Session</h2>
      <p>Piece: {currentSession.piece}</p>
      <p>Composer: {currentSession.composer}</p>
      <p>Status: {isRecording ? 'Recording...' : 'Paused'}</p>
      
      <button onClick={endSession}>End Session</button>
    </div>
  );
}

export default SessionDisplay;
```

```javascript
// SessionDisplay.test.js
import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SessionDisplay from './SessionDisplay';
import { PracticeSessionProvider } from './PracticeSessionProvider';

function renderWithProvider(ui) {
  return render(
    <PracticeSessionProvider>
      {ui}
    </PracticeSessionProvider>
  );
}

describe('SessionDisplay', () => {
  it('is expected to show no session message when no session is active', () => {
    renderWithProvider(<SessionDisplay />);

    expect(screen.getByText('No active session')).toBeInTheDocument();
    expect(screen.getByText('Start New Session')).toBeInTheDocument();
  });

  it('is expected to start a new session when button is clicked', async () => {
    const user = userEvent.setup();
    renderWithProvider(<SessionDisplay />);

    await user.click(screen.getByText('Start New Session'));

    expect(screen.getByText('Current Session')).toBeInTheDocument();
    expect(screen.getByText('Piece: New Practice')).toBeInTheDocument();
    expect(screen.getByText('Status: Recording...')).toBeInTheDocument();
  });

  it('is expected to end session when end button is clicked', async () => {
    const user = userEvent.setup();
    renderWithProvider(<SessionDisplay />);

    // Start a session
    await user.click(screen.getByText('Start New Session'));
    expect(screen.getByText('Current Session')).toBeInTheDocument();

    // End the session
    await user.click(screen.getByText('End Session'));
    expect(screen.getByText('No active session')).toBeInTheDocument();
  });
});
```

:::

## The testing tools you'll need to know

Now let's talk about the broader ecosystem of testing tools available for React applications. Each tool has its strengths and ideal use cases.

### Jest: Your testing foundation {.unnumbered .unlisted}

Jest is the most popular testing framework for React applications, and for good reason:

**Strengths:**

- Zero configuration for most React projects
- Excellent mocking capabilities
- Built-in assertions and test runners
- Great error messages and debugging tools
- Snapshot testing for component output
- Code coverage reporting

**When to use Jest:**

- Unit testing components and functions
- Testing custom hooks
- Mocking external dependencies
- Running test suites in CI/CD

**Jest configuration example:**


::: example

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  moduleNameMapping: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx}',
    '!src/index.js',
    '!src/reportWebVitals.js'
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  }
};
```

:::

### React Testing Library: Test what users see {.unnumbered .unlisted}

React Testing Library has become the standard for testing React components because it encourages testing from the user's perspective:

**Philosophy:**

- Tests should resemble how users interact with your app
- Focus on behavior, not implementation details
- If it's not something a user can see or do, you probably shouldn't test it

**Common queries and their use cases:**


::: example

```javascript
// Good: Testing what users can see and do
expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();
expect(screen.getByLabelText('Email address')).toHaveValue('user@example.com');
expect(screen.getByText('Welcome, John!')).toBeInTheDocument();

// Less ideal: Testing implementation details
expect(wrapper.find('.submit-button')).toHaveLength(1);
expect(component.state.email).toBe('user@example.com');
```

:::

### Cypress: For when you need the full picture {.unnumbered .unlisted}

Cypress isn't just for end-to-end testing--you can also use it to test React components in isolation:

**Cypress Component Testing setup:**


::: example

```javascript
// cypress.config.js
import { defineConfig } from 'cypress'

export default defineConfig({
  component: {
    devServer: {
      framework: 'create-react-app',
      bundler: 'webpack',
    },
  },
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
})
```

```jsx
// PracticeTimer.cy.jsx
import PracticeTimer from './PracticeTimer'

describe('PracticeTimer Component', () => {
  it('is expected to start and stop timer', () => {
    const onComplete = cy.stub();
    
    cy.mount(<PracticeTimer onComplete={onComplete} />);
    
    cy.contains('0:00').should('be.visible');
    cy.contains('Start').click();
    
    cy.wait(2000);
    cy.contains('0:02').should('be.visible');
    
    cy.contains('Pause').click();
    cy.contains('Start').should('be.visible');
  });

  it('is expected to call onComplete when session is finished', () => {
    const onComplete = cy.stub();
    
    cy.mount(<PracticeTimer onComplete={onComplete} />);
    
    cy.contains('Start').click();
    cy.wait(1000);
    cy.contains('Complete Session').click();
    
    cy.then(() => {
      expect(onComplete).to.have.been.calledWith(1);
    });
  });
});
```

:::

**When to use Cypress for component testing:**

- Visual regression testing
- Complex user interactions
- Testing components that integrate with external libraries
- When you want to see your components running in a real browser

### Other tools in the testing ecosystem {.unnumbered .unlisted}

**Mocha + Chai**: Alternative to Jest, popular in the JavaScript ecosystem
- Mocha provides the test runner and structure
- Chai provides assertions
- More modular but requires more configuration

**Vitest**: Modern alternative to Jest, especially for Vite-based projects
- Faster execution
- Better ES modules support
- Similar API to Jest

**Playwright**: Alternative to Cypress for E2E testing
- Better performance for large test suites
- Built-in cross-browser testing
- Excellent debugging tools

## Integration testing strategies

Integration tests verify that multiple components work together correctly. They're especially valuable for testing user workflows and data flow between components.

### Testing multiple components together {.unnumbered .unlisted}

::: example

```jsx
// PracticeWorkflow.jsx - A complex component that integrates multiple pieces
import React, { useState } from 'react';
import PracticeTimer from './PracticeTimer';
import SessionNotes from './SessionNotes';
import PieceSelector from './PieceSelector';
import { usePracticeSession } from './PracticeSessionProvider';

function PracticeWorkflow() {
  const [selectedPiece, setSelectedPiece] = useState(null);
  const [notes, setNotes] = useState('');
  const { startSession, endSession, currentSession } = usePracticeSession();

  const handleStartPractice = () => {
    if (!selectedPiece) return;
    
    startSession({
      piece: selectedPiece.title,
      composer: selectedPiece.composer,
      difficulty: selectedPiece.difficulty
    });
  };

  const handleCompletePractice = (practiceTime) => {
    const session = endSession();
    
    // Save notes with the session
    if (notes.trim()) {
      session.notes = notes;
    }
    
    return session;
  };

  if (currentSession) {
    return (
      <div className="practice-active">
        <h2>Practicing: {currentSession.piece}</h2>
        <PracticeTimer onComplete={handleCompletePractice} />
        <SessionNotes value={notes} onChange={setNotes} />
      </div>
    );
  }

  return (
    <div className="practice-setup">
      <h2>Start New Practice Session</h2>
      <PieceSelector 
        selectedPiece={selectedPiece} 
        onPieceSelect={setSelectedPiece} 
      />
      
      <button 
        onClick={handleStartPractice}
        disabled={!selectedPiece}
        className="start-practice-btn"
      >
        Start Practice
      </button>
    </div>
  );
}

export default PracticeWorkflow;
```

```javascript
// PracticeWorkflow.test.js
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import PracticeWorkflow from './PracticeWorkflow';
import { PracticeSessionProvider } from './PracticeSessionProvider';

// Mock child components to isolate integration testing
jest.mock('./PracticeTimer', () => {
  return function MockPracticeTimer({ onComplete }) {
    return (
      <div data-testid="practice-timer">
        <div>Timer Running</div>
        <button onClick={() => onComplete(300)}>Complete (5 min)</button>
      </div>
    );
  };
});

jest.mock('./SessionNotes', () => {
  return function MockSessionNotes({ value, onChange }) {
    return (
      <textarea
        data-testid="session-notes"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Practice notes..."
      />
    );
  };
});

jest.mock('./PieceSelector', () => {
  return function MockPieceSelector({ onPieceSelect }) {
    const pieces = [
      { id: 1, title: 'Moonlight Sonata', composer: 'Beethoven' },
      { id: 2, title: 'Fur Elise', composer: 'Beethoven' }
    ];

    return (
      <div data-testid="piece-selector">
        {pieces.map(piece => (
          <button
            key={piece.id}
            onClick={() => onPieceSelect(piece)}
          >
            {piece.title}
          </button>
        ))}
      </div>
    );
  };
});

function renderWithProvider(ui) {
  return render(
    <PracticeSessionProvider>
      {ui}
    </PracticeSessionProvider>
  );
}

describe('PracticeWorkflow Integration', () => {
  it('is expected to complete full practice workflow', async () => {
    const user = userEvent.setup();
    renderWithProvider(<PracticeWorkflow />);

    // Initial setup state
    expect(screen.getByText('Start New Practice Session')).toBeInTheDocument();
    expect(screen.getByText('Start Practice')).toBeDisabled();

    // Select a piece
    await user.click(screen.getByText('Moonlight Sonata'));
    expect(screen.getByText('Start Practice')).toBeEnabled();

    // Start practice session
    await user.click(screen.getByText('Start Practice'));

    // Should now be in practice mode
    expect(screen.getByText('Practicing: Moonlight Sonata')).toBeInTheDocument();
    expect(screen.getByTestId('practice-timer')).toBeInTheDocument();
    expect(screen.getByTestId('session-notes')).toBeInTheDocument();

    // Add some notes
    await user.type(screen.getByTestId('session-notes'), 'Worked on dynamics in measures 5-8');

    // Complete the session
    await user.click(screen.getByText('Complete (5 min)'));

    // Verify API was called
    await waitFor(() => {
      expect(screen.getByText('Session saved successfully')).toBeInTheDocument();
    });
  });
});
```

:::

## Running tests automatically

Testing is most valuable when it's automated and runs on every code change. Let's look at setting up testing in CI/CD pipelines. (We'll cover deployment in more detail in Chapter 9.)

### Getting tests to run in CI {.unnumbered .unlisted}

Here's a complete GitHub Actions workflow for running React tests automatically. Remember, we'll dive deeper into CI/CD strategies and deployment pipelines in Chapter 9.

::: example

```yaml
# .github/workflows/test.yml
name: Test React Application

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:

    - uses: actions/checkout@v4
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run tests
      run: npm test -- --coverage --watchAll=false
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      if: matrix.node-version == '20.x'
      
    - name: Build application
      run: npm run build
:::

**Key points about this CI setup:**

- **Multiple Node versions**: Tests against different Node versions to catch compatibility issues
- **Coverage reporting**: Generates test coverage and uploads to Codecov  
- **Includes linting**: Runs code quality checks alongside tests
- **Build verification**: Ensures the app builds successfully after tests pass
- **Conditional steps**: Only uploads coverage once to avoid duplicates

This basic setup ensures your tests run automatically on every push and pull request. In Chapter 9, we'll explore more advanced CI/CD patterns including deployment strategies, environment-specific testing, and integration with monitoring systems.

### Organizing your test files {.unnumbered .unlisted}

Good test organization makes your test suite maintainable and helps other developers understand what's being tested. Here are several proven approaches:

**Option 1: Co-located tests (Recommended for most projects)**

::: example

```
src/
  components/
    PracticeTimer/
      PracticeTimer.jsx
      PracticeTimer.test.js
      PracticeTimer.stories.js
    SessionDisplay/
      SessionDisplay.jsx
      SessionDisplay.test.js
  hooks/
    usePracticeTimer/
      usePracticeTimer.js
      usePracticeTimer.test.js
  providers/
    PracticeSessionProvider/
      PracticeSessionProvider.jsx
      PracticeSessionProvider.test.js
  __tests__/
    integration/
      PracticeWorkflow.integration.test.js
      UserJourney.integration.test.js
    e2e/
      practice-session.e2e.test.js
    setup/
      setupTests.js
      testUtils.js
```

:::

**Option 2: Separate test directory (Good for large projects)**

::: example

```
src/
  components/
    PracticeTimer/
      PracticeTimer.jsx
    SessionDisplay/
      SessionDisplay.jsx
  hooks/
    usePracticeTimer.js
  providers/
    PracticeSessionProvider.jsx

tests/
  unit/
    components/
      PracticeTimer.test.js
      SessionDisplay.test.js
    hooks/
      usePracticeTimer.test.js
    providers/
      PracticeSessionProvider.test.js
  integration/
    PracticeWorkflow.integration.test.js
  e2e/
    practice-session.e2e.test.js
  setup/
    setupTests.js
    testUtils.js
```

:::

**Test naming conventions:**

- **Unit tests**: `ComponentName.test.js`
- **Integration tests**: `FeatureName.integration.test.js`  
- **E2E tests**: `user-flow.e2e.test.js`
- **Utility files**: `testUtils.js`, `setupTests.js`

:::

## Things to watch out for

Let me share some hard-learned lessons about what works and what doesn't in React testing.

### Finding the sweet spot for testing {.unnumbered .unlisted}**DO test:**

- Component behavior that users can observe
- Props affecting rendered output
- User interactions and their effects
- Error states and edge cases
- Custom hooks with complex logic
- Integration between components

**DON'T test:**

- Implementation details (internal state structure, specific function calls)
- Third-party library behavior
- Browser APIs (unless you're wrapping them)
- CSS styling (unless it affects functionality)
- Trivial components with no logic

### Avoiding testing traps {.unnumbered .unlisted}::: example

```javascript
// [BAD] Testing implementation details
it('calls useState with correct initial value', () => {
  const useStateSpy = jest.spyOn(React, 'useState');
  render(<MyComponent />);
  expect(useStateSpy).toHaveBeenCalledWith(0);
});

// [GOOD] Testing observable behavior
it('displays initial count of 0', () => {
  render(<MyComponent />);
  expect(screen.getByText('Count: 0')).toBeInTheDocument();
});

// [BAD] Over-mocking
jest.mock('./MyComponent', () => {
  return {
    __esModule: true,
    default: () => <div>Mocked Component</div>
  };
});

// [GOOD] Mock only external dependencies
jest.mock('../api/practiceAPI');

// [BAD] Testing library code
it('useState updates state correctly', () => {
  // This tests React's useState, not your code
});

// [GOOD] Testing your component's use of state
it('increments counter when button is clicked', () => {
  // This tests your component's behavior
});
```

:::

### How to name your tests well {.unnumbered .unlisted}

Good test names make failures easier to understand:

::: example

```javascript
// [BAD] Bad test names
it('works correctly');
it('timer test');
it('should work');

// [GOOD] Good test names
it('displays formatted time correctly');
it('calls onComplete when timer reaches zero');
it('prevents starting timer when already running');
it('resets timer to initial state when reset button is clicked');
```

:::

### When tests fail (and how to fix them) {.unnumbered .unlisted}

When tests fail, here are strategies to debug them effectively:

**First and most importantly: READ THE ERROR MESSAGE**. I cannot stress this enough. I know Jest and React Testing Library can produce intimidating error messages, but they're actually trying to help you. Here's how to decode them:

::: example

```javascript
// When you see an error like this:
// * PracticeTimer > is expected to start timer when button clicked
//   
//   TestingLibraryElementError: Unable to find an accessible element with the role "button" and name "Start"
//   
//   Here are the accessible roles:
//   
//     button:
//   
//     Name "Begin Practice":
//     <button />
//   
//     Name "Reset":
//     <button />

// This error is actually being super helpful:
// 1. It tells you what test failed and why
// 2. It shows you what buttons actually exist
// 3. It reveals the mismatch: you're looking for "Start" but the button says "Begin Practice"

// This is usually a test problem, not a component problem. Fix it like this:
it('is expected to start timer when button is clicked', async () => {
  const user = userEvent.setup();
  render(<PracticeTimer />);
  
  // Use the actual button text (or update your component if the text is wrong)
  await user.click(screen.getByRole('button', { name: 'Begin Practice' }));
  
  expect(screen.getByText('Pause')).toBeInTheDocument();
});
```

:::

**Common debugging patterns:**


::: example

```javascript
// Step-by-step debugging approach
it('is expected to handle complex user interaction', async () => {
  const user = userEvent.setup();
  render(<ComplexForm />);
  
  // Use screen.debug() to see current DOM
  screen.debug();
  
  // Look for elements step by step
  const saveButton = screen.getByRole('button', { name: /save/i });
  expect(saveButton).toBeInTheDocument();
  
  // Use query to check for absence
  expect(screen.queryByText('Success')).not.toBeInTheDocument();
  
  // Perform action
  await user.click(saveButton);
  
  // Debug again after state change
  screen.debug();
  
  // Check result
  await waitFor(() => {
    expect(screen.getByText('Success')).toBeInTheDocument();
  });
});

// Use data-testid for complex selectors
function Dashboard({ user, notifications }) {
  return (
    <div>
      <h1>Welcome, {user.name}</h1>
      <div data-testid="notification-count">
        {notifications.length} new notifications
      </div>
      <div data-testid="user-actions">
        <button onClick={user.onLogout}>Log Out</button>
        <button onClick={user.onProfile}>Profile</button>
      </div>
    </div>
  );
}

// Then in tests
expect(screen.getByTestId('notification-count')).toHaveTextContent('3 new');
expect(screen.getByTestId('user-actions')).toBeInTheDocument();
```

:::

**Distinguishing between component bugs and test bugs:**


When a test fails, ask yourself:
1. **Is the component broken?** Test manually in the browser to see if the component actually works.
2. **Is the test flaky?** Run the test multiple times. If it passes sometimes and fails other times, it's likely a timing issue.
3. **Is the test wrong?** Check if your test expectations match what the component actually does.

::: example

```javascript
// Flaky test example - timing issue
it('is expected to update timer after 3 seconds', async () => {
  render(<PracticeTimer />);
  
  await user.click(screen.getByText('Start'));
  
  // [BAD] Flaky - real timers are unpredictable in tests
  await new Promise(resolve => setTimeout(resolve, 3000));
  expect(screen.getByText('0:03')).toBeInTheDocument();
  
  // [GOOD] Better - use fake timers
  jest.useFakeTimers();
  await user.click(screen.getByText('Start'));
  act(() => {
    jest.advanceTimersByTime(3000);
  });
  expect(screen.getByText('0:03')).toBeInTheDocument();
  jest.useRealTimers();
});

// Component bug vs test bug
it('is expected to show loading state', async () => {
  const user = userEvent.setup();
  render(<UserProfile userId="123" />);
  
  // If this fails, check in browser first
  await user.click(screen.getByText('Refresh'));
  
  // Should see loading immediately
  expect(screen.getByText('Loading...')).toBeInTheDocument();
  
  // Wait for loading to finish
  await waitFor(() => {
    expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
  });
});
```

:::

**Pro tip**: When debugging, temporarily add `screen.debug()` calls to see exactly what's being rendered at any point in your test. This is often more helpful than staring at error messages. Remove the debug calls once you've fixed the issue.

**Quick debugging checklist:**

1. Read the error message carefully
2. Use `screen.debug()` to see actual DOM
3. Check if elements exist with `queryBy*` first
4. Verify timing with `waitFor()` for async operations
5. Test the component manually in browser
6. Check imports and mocks are correct

### Advanced debugging techniques {.unnumbered .unlisted}

When your tests get more complex, your debugging needs to level up too. Here are the power-user techniques that will save you hours of frustration.

**Visual debugging with screen.debug()**

The `screen.debug()` function is your best friend, but you can make it even more powerful:

::: example

```javascript
it('is expected to handle complex state transitions', async () => {
  const user = userEvent.setup();
  render(<ShoppingCart items={initialItems} />);
  
  // Debug the entire DOM
  screen.debug();
  
  // Debug only a specific element
  const cartContainer = screen.getByTestId('cart-items');
  screen.debug(cartContainer);
  
  // Debug with custom formatting
  screen.debug(undefined, 20000); // Show more lines
  
  await user.click(screen.getByText('Remove'));
  
  // Debug after action to see what changed
  screen.debug(cartContainer);
});
```

:::

**Using logTestingPlaygroundURL for complex selectors**

When you can't figure out the right selector, React Testing Library can generate one for you:

::: example

```javascript
import { screen, logTestingPlaygroundURL } from '@testing-library/react';

it('is expected to find the right element', () => {
  render(<ComplexForm />);
  
  // This opens testing-playground.com with your DOM loaded
  logTestingPlaygroundURL();
  
  // You can click on elements in the playground to get the right selector
  // Then copy it back to your test
});
```

:::

**Debugging timing and async issues**

Most test bugs are timing-related. Here's how to debug them systematically:

::: example

```javascript
// Debugging async operations step by step
it('is expected to handle async form submission', async () => {
  const mockSubmit = jest.fn().mockResolvedValue({ success: true });
  const user = userEvent.setup();
  
  render(<ContactForm onSubmit={mockSubmit} />);
  
  // Fill form
  await user.type(screen.getByLabelText('Email'), 'test@example.com');
  await user.type(screen.getByLabelText('Message'), 'Hello world');
  
  // Submit
  await user.click(screen.getByRole('button', { name: 'Send' }));
  
  // Debug: what's the form state right after click?
  screen.debug();
  
  // Look for loading state first
  expect(screen.getByText('Sending...')).toBeInTheDocument();
  
  // Wait for completion - with debugging
  await waitFor(
    () => {
      expect(screen.getByText('Message sent!')).toBeInTheDocument();
    },
    {
      timeout: 3000,
      onTimeout: (error) => {
        // Debug when waitFor times out
        console.log('waitFor timed out, current DOM:');
        screen.debug();
        return error;
      }
    }
  );
});
```

:::

**Custom debugging utilities**

Create your own debugging helpers for common patterns:

::: example

```javascript
// utils/test-debug.js
export const debugFormState = (formElement) => {
  const inputs = formElement.querySelectorAll('input, select, textarea');
  const formData = new FormData(formElement);
  
  console.log('Form state:');
  for (const [key, value] of formData.entries()) {
    console.log(`  ${key}: ${value}`);
  }
  
  console.log('Validation states:');
  inputs.forEach(input => {
    console.log(`  ${input.name}: valid=${input.validity.valid}`);
  });
};

// Use in tests
import { debugFormState } from '../utils/test-debug';

it('is expected to validate form correctly', async () => {
  const user = userEvent.setup();
  render(<SignupForm />);
  
  const form = screen.getByRole('form');
  
  // Debug initial state
  debugFormState(form);
  
  await user.type(screen.getByLabelText('Email'), 'invalid-email');
  
  // Debug after input
  debugFormState(form);
});
```

:::

## Testing error boundaries and error states

Error boundaries are a critical React feature, but they're often overlooked in testing. Here's how to test them properly and ensure your app handles failures gracefully.

**Basic error boundary testing**

::: example

```javascript
// ErrorBoundary.js
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    // Log to monitoring service
    console.error('Error boundary caught error:', error, errorInfo);
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <div>Something went wrong.</div>;
    }

    return this.props.children;
  }
}

// ErrorBoundary.test.js
const ThrowError = ({ shouldThrow }) => {
  if (shouldThrow) {
    throw new Error('Test error');
  }
  return <div>No error</div>;
};

describe('ErrorBoundary', () => {
  // Suppress console.error for these tests
  beforeEach(() => {
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    console.error.mockRestore();
  });

  it('is expected to render children when there is no error', () => {
    render(
      <ErrorBoundary>
        <ThrowError shouldThrow={false} />
      </ErrorBoundary>
    );

    expect(screen.getByText('No error')).toBeInTheDocument();
  });

  it('is expected to render error message when child throws', () => {
    render(
      <ErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ErrorBoundary>
    );

    expect(screen.getByText('Something went wrong.')).toBeInTheDocument();
    expect(screen.queryByText('No error')).not.toBeInTheDocument();
  });

  it('is expected to call onError callback when error occurs', () => {
    const mockOnError = jest.fn();
    
    render(
      <ErrorBoundary onError={mockOnError}>
        <ThrowError shouldThrow={true} />
      </ErrorBoundary>
    );

    expect(mockOnError).toHaveBeenCalledWith(
      expect.any(Error),
      expect.objectContaining({
        componentStack: expect.any(String)
      })
    );
  });
});
```

:::

**Testing async error states**

Many errors happen during async operations. Here's how to test those scenarios:

::: example

```javascript
// DataLoader.js
function DataLoader({ userId }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        setError(null);
        const userData = await fetchUser(userId);
        setData(userData);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!data) return <div>No data found</div>;

  return (
    <div>
      <h1>{data.name}</h1>
      <p>{data.email}</p>
    </div>
  );
}

// DataLoader.test.js
import { fetchUser } from '../api/users';

jest.mock('../api/users');

describe('DataLoader', () => {
  beforeEach(() => {
    fetchUser.mockClear();
  });

  it('is expected to show error when fetch fails', async () => {
    const errorMessage = 'Failed to fetch user';
    fetchUser.mockRejectedValue(new Error(errorMessage));
    
    render(<DataLoader userId="123" />);
    
    // Loading state
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    
    // Error state
    await waitFor(() => {
      expect(screen.getByText(`Error: ${errorMessage}`)).toBeInTheDocument();
    });
    
    expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
  });
});
```

:::

## Advanced async component testing

Async operations are everywhere in modern React apps. Here's how to test them comprehensively, from simple loading states to complex async interactions.

**Testing complex async flows**

::: example

```javascript
// Multi-step async component
function OrderProcessor({ orderId }) {
  const [step, setStep] = useState('validating');
  const [order, setOrder] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const processOrder = async () => {
      try {
        setStep('validating');
        await validateOrder(orderId);
        
        setStep('loading');
        const orderData = await fetchOrder(orderId);
        setOrder(orderData);
        
        setStep('processing');
        await processPayment(orderData.paymentId);
        
        setStep('completed');
      } catch (err) {
        setError(err.message);
        setStep('error');
      }
    };

    processOrder();
  }, [orderId]);

  if (step === 'validating') return <div>Validating order...</div>;
  if (step === 'loading') return <div>Loading order details...</div>;
  if (step === 'processing') return <div>Processing payment...</div>;
  if (step === 'error') return <div>Error: {error}</div>;
  if (step === 'completed') return <div>Order complete!</div>;

  return null;
}

// Testing the complete flow
describe('OrderProcessor', () => {
  it('is expected to complete successful order flow', async () => {
    const mockOrder = { id: '123', paymentId: 'pay_456', total: 99.99 };
    
    validateOrder.mockResolvedValue(true);
    fetchOrder.mockResolvedValue(mockOrder);
    processPayment.mockResolvedValue({ success: true });
    
    render(<OrderProcessor orderId="123" />);
    
    // Step 1: Validation
    expect(screen.getByText('Validating order...')).toBeInTheDocument();
    
    // Step 2: Loading
    await waitFor(() => {
      expect(screen.getByText('Loading order details...')).toBeInTheDocument();
    });
    
    // Step 3: Processing
    await waitFor(() => {
      expect(screen.getByText('Processing payment...')).toBeInTheDocument();
    });
    
    // Step 4: Completed
    await waitFor(() => {
      expect(screen.getByText('Order complete!')).toBeInTheDocument();
    });
    
    // Verify all functions were called in order
    expect(validateOrder).toHaveBeenCalledWith('123');
    expect(fetchOrder).toHaveBeenCalledWith('123');
    expect(processPayment).toHaveBeenCalledWith('pay_456');
  });
});
```

:::

## Technical debt and testing legacy code

Let's be honest: most of us aren't working on greenfield projects. You're probably dealing with legacy code, technical debt, and the challenge of adding tests to existing applications. Here's how to approach this systematically.

**Starting with characterization tests**

When you inherit legacy code, start by writing "characterization tests" - tests that document what the code currently does, not necessarily what it should do:

::: example

```javascript
// Legacy component that needs testing
class UserProfile extends Component {
  constructor(props) {
    super(props);
    this.state = { user: null, loading: true, editing: false };
  }

  async componentDidMount() {
    try {
      const response = await fetch(`/api/users/${this.props.userId}`);
      const user = await response.json();
      this.setState({ user, loading: false });
    } catch (error) {
      this.setState({ loading: false });
      alert('Failed to load user');
    }
  }

  render() {
    const { user, loading, editing } = this.state;
    
    if (loading) return <div>Loading...</div>;
    if (!user) return <div>User not found</div>;

    return (
      <div>
        <h1>{user.name}</h1>
        <p>{user.email}</p>
        <button onClick={() => this.setState({ editing: true })}>Edit</button>
      </div>
    );
  }
}

// Characterization tests - document current behavior
describe('UserProfile - characterization tests', () => {
  beforeEach(() => {
    global.fetch = jest.fn();
    global.alert = jest.fn();
  });

  afterEach(() => {
    jest.resetAllMocks();
  });

  it('is expected to show user data after successful fetch', async () => {
    const mockUser = { id: '123', name: 'John Doe', email: 'john@example.com' };
    fetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve(mockUser)
    });
    
    render(<UserProfile userId="123" />);
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('is expected to show alert when fetch fails', async () => {
    fetch.mockRejectedValue(new Error('Network error'));
    
    render(<UserProfile userId="123" />);
    
    await waitFor(() => {
      expect(global.alert).toHaveBeenCalledWith('Failed to load user');
    });
  });
});
```

:::

**Incremental refactoring with test coverage**

Once you have characterization tests, you can safely refactor. Extract functions, improve error handling, and modernize gradually while maintaining test coverage.

The key is not to rewrite everything at once, but to gradually improve code quality while maintaining test coverage and system stability.

## Chapter summary

You've just learned how to test React components in a practical, sustainable way. Let's recap the key insights that will serve you well as you build your testing practice.

### The mindset shift {.unnumbered .unlisted}

The biggest takeaway from this chapter isn't about any specific tool or technique--it's about changing how you think about testing:

- **Testing is about confidence, not coverage**: A few well-written tests that cover your critical user flows are worth more than dozens of tests that check implementation details.
- **Start where you are**: You don't need to test everything from day one. Begin with your most important components and gradually expand.
- **Test like a user**: Focus on what users can see and do, not on how your code works internally.

### What you should remember {.unnumbered .unlisted}

**Start with what matters**: Test the behavior your users care about, not implementation details. If clicking a button should save data, test that the save function gets called--don't test that the button has a specific CSS class.

**Build incrementally**: It's better to have some tests than no tests. Add testing gradually to existing projects rather than feeling overwhelmed by the need to test everything at once.

**Use the right tools**: Jest and React Testing Library will handle 90% of your testing needs. Reach for Cypress when you need full browser integration, but don't overcomplicate your setup.

**Test at the right level**: Balance unit tests (fast, focused), integration tests (realistic interactions), and e2e tests (full user journeys) based on what gives you the most confidence.

**Make tests maintainable**: Good test organization and clear naming conventions will make your test suite an asset that helps the team move faster, not a burden that slows you down.

### Your path forward {.unnumbered .unlisted}

Here's a practical roadmap for introducing testing to your React applications:

**Week 1-2: Start small**
- Pick your most critical component (probably one with business logic)
- Write 3-4 tests covering the main user interactions
- Get comfortable with the basic render -> interact -> assert pattern

**Week 3-4: Add component coverage**
- Test 2-3 more components, focusing on ones with props and state
- Practice testing different scenarios (error states, edge cases)
- Start mocking external dependencies

**Month 2: Expand to hooks and integration**
- Write tests for any custom hooks you have
- Add a few integration tests for key user workflows
- Set up automated testing in your CI pipeline

**Month 3+: Optimize and maintain**
- Refactor tests as your components evolve
- Add e2e tests for your most critical user journeys
- Share testing knowledge with your team

### Resources for continued learning {.unnumbered .unlisted}

- **For advanced testing strategies**: "The Green Line: A Journey Into Automated Testing" provides comprehensive coverage of testing philosophy and e2e techniques
- **For React Testing Library specifics**: The official docs at testing-library.com are excellent
- **For testing mindset**: Kent C. Dodds' blog posts on testing best practices

Remember, testing is a skill that improves with practice. Your first tests might feel awkward, and you'll probably test too much or too little at first. That's completely normal. The important thing is to start, learn from what works and what doesn't, and gradually develop your testing instincts.

The goal isn't perfect test coverage--it's building confidence in your code and making your development process more reliable and enjoyable. Start where you are, test what matters most, and let your testing strategy evolve naturally with your application.
