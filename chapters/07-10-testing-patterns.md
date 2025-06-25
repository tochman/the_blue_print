# Testing Advanced Component Patterns

Testing advanced React patterns requires a sophisticated approach that goes beyond simple unit tests. As covered in detail in Chapter 5, we'll follow behavior-driven development (BDD) principles and focus on testing user workflows rather than implementation details.

::: note
**Reference to Chapter 5**

This section provides specific testing strategies for advanced patterns. For comprehensive testing fundamentals, testing setup, and detailed BDD methodology, see Chapter 5: Testing React Components. We'll follow the same BDD style and testing principles established there.
:::

Testing compound components, provider hierarchies, and custom hooks with state machines isn't straightforward. These patterns have emergent behavior—their real value comes from how multiple pieces work together, not just individual component logic. This means our testing strategies need to focus on integration scenarios and user workflows that reflect real-world usage.

Advanced testing patterns focus on behavior verification rather than implementation details, enabling tests that remain stable as implementations evolve. These patterns also emphasize testing user workflows and integration scenarios that reflect real-world usage patterns.

::: important
**Testing behavior, not implementation**

Advanced component testing should focus on user-observable behavior and component contracts rather than internal implementation details. This approach creates more maintainable tests that provide confidence in functionality while allowing for refactoring and optimization.
:::

## Testing Compound Components with BDD Approach

Following the BDD methodology from Chapter 5, we'll structure our compound component tests around user scenarios and behaviors rather than implementation details.

::: example

```jsx
// BDD-style testing utilities for compound components
describe('SessionPlayer Compound Component', () => {
  describe('When rendering with child components', () => {
    it('is expected to provide shared context to all children', async () => {
      // Given a session player with various child components
      const mockSession = {
        id: 'test-session',
        title: 'Bach Invention No. 1', 
        duration: 180,
        audioUrl: '/test-audio.mp3'
      };

      // When rendering the compound component
      render(
        <SessionPlayer session={mockSession}>
          <SessionPlayer.Title />
          <SessionPlayer.Controls />
          <SessionPlayer.Progress />
        </SessionPlayer>
      );

      // Then all children should receive session context
      expect(screen.getByText('Bach Invention No. 1')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /play/i })).toBeInTheDocument();
      expect(screen.getByRole('progressbar')).toBeInTheDocument();
    });

    it('is expected to coordinate state changes across child components', async () => {
      // Given a session player with controls and progress display
      const mockSession = createMockSession();
      
      render(
        <SessionPlayer session={mockSession}>
          <SessionPlayer.Controls />
          <SessionPlayer.Progress />
        </SessionPlayer>
      );

      // When user starts playback
      const playButton = screen.getByRole('button', { name: /play/i });
      await user.click(playButton);

      // Then the controls should update and progress should begin
      expect(screen.getByRole('button', { name: /pause/i })).toBeInTheDocument();
      
      // And progress should be trackable
      const progressBar = screen.getByRole('progressbar');
      expect(progressBar).toHaveAttribute('aria-valuenow', '0');
    });
  });

  describe('When handling user interactions', () => {
    it('is expected to allow seeking through waveform interaction', async () => {
      // Given a session player with waveform and progress
      const onTimeUpdate = vi.fn();
      
      render(
        <SessionPlayer session={createMockSession()}>
          <SessionPlayer.Waveform onTimeUpdate={onTimeUpdate} />
          <SessionPlayer.Progress />
        </SessionPlayer>
      );

      // When user clicks on waveform to seek
      const waveform = screen.getByTestId('waveform');
      await user.click(waveform);

      // Then time should update and seeking should be indicated
      expect(onTimeUpdate).toHaveBeenCalledWith(
        expect.objectContaining({
          currentTime: expect.any(Number),
          seeking: true
        })
      );
    });
  });

  describe('When encountering errors', () => {
    it('is expected to isolate errors to individual child components', () => {
      // Given a compound component with a failing child
      const ErrorThrowingChild = () => {
        throw new Error('Test error');
      };

      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

      // When rendering with the failing child
      render(
        <SessionPlayer session={createMockSession()}>
          <SessionPlayer.Title />
          <ErrorThrowingChild />
          <SessionPlayer.Controls />
        </SessionPlayer>
      );

      // Then other children should still render correctly
      expect(screen.getByTestId('session-title')).toBeInTheDocument();
      expect(screen.getByTestId('session-controls')).toBeInTheDocument();

      consoleSpy.mockRestore();
    });
  });
});
```

:::

## Testing Custom Hooks with BDD Style

Following Chapter 5's approach, we'll test custom hooks by focusing on their behavior and the scenarios they handle, not their internal implementation.

::: example

```jsx
// BDD-style testing for complex custom hooks
describe('usePracticeSession Hook', () => {
  let mockServices;

  beforeEach(() => {
    mockServices = {
      api: {
        createSession: vi.fn(),
        updateSession: vi.fn(),
        saveProgress: vi.fn()
      },
      analytics: { track: vi.fn() },
      notifications: { show: vi.fn() }
    };
  });

  describe('When creating a new practice session', () => {
    it('is expected to successfully create and track the session', async () => {
      // Given a hook with mock services
      const mockSession = { id: 'new-session', title: 'Test Session' };
      mockServices.api.createSession.mockResolvedValue(mockSession);

      const { result } = renderHook(() => usePracticeSession(), {
        wrapper: createMockProvider(mockServices)
      });

      // When creating a session
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      // Then the session should be created and tracked
      await waitFor(() => {
        expect(result.current.session).toEqual(mockSession);
        expect(mockServices.analytics.track).toHaveBeenCalledWith(
          'session_created',
          { sessionId: 'new-session' }
        );
      });
    });

    it('is expected to handle creation errors gracefully', async () => {
      // Given a service that will fail
      const error = new Error('Creation failed');
      mockServices.api.createSession.mockRejectedValue(error);

      const { result } = renderHook(() => usePracticeSession(), {
        wrapper: createMockProvider(mockServices)
      });

      // When attempting to create a session
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      // Then the error should be handled and user notified
      await waitFor(() => {
        expect(result.current.error).toEqual(error);
        expect(mockServices.notifications.show).toHaveBeenCalledWith(
          'Failed to create session',
          'error'
        );
      });
    });
  });

  describe('When auto-saving session progress', () => {
    it('is expected to save progress at configured intervals', async () => {
      // Given a session with auto-save enabled
      const mockSession = { id: 'test-session', title: 'Test Session' };
      mockServices.api.createSession.mockResolvedValue(mockSession);
      mockServices.api.saveProgress.mockResolvedValue({ success: true });

      const { result } = renderHook(
        () => usePracticeSession({ autoSaveInterval: 5000 }),
        { wrapper: createMockProvider(mockServices) }
      );

      // When session is created and progress is updated
      act(() => {
        result.current.createSession({ title: 'Test Session' });
      });

      await waitFor(() => {
        expect(result.current.session).toEqual(mockSession);
      });

      act(() => {
        result.current.updateProgress({ currentTime: 30, notes: 'Good progress' });
        vi.advanceTimersByTime(5000);
      });

      // Then progress should be auto-saved
      await waitFor(() => {
        expect(mockServices.api.saveProgress).toHaveBeenCalledWith(
          'test-session',
          expect.objectContaining({
            currentTime: 30,
            notes: 'Good progress'
          })
        );
      });
    });
  });
});
```

:::

## Testing provider patterns and context systems

Provider-based architectures require testing strategies that can verify proper dependency injection, context value propagation, and service coordination across component hierarchies.

::: example

```jsx
// Provider testing utilities
function createProviderTester(ProviderComponent) {
  const renderWithProvider = (children, providerProps = {}) => {
    return render(
      <ProviderComponent {...providerProps}>
        {children}
      </ProviderComponent>
    );
  };

  const renderWithoutProvider = (children) => {
    return render(children);
  };

  return {
    renderWithProvider,
    renderWithoutProvider
  };
}

// Service injection testing
describe('ServiceContainer Provider', () => {
  let mockServices;
  let TestConsumer;

  beforeEach(() => {
    mockServices = {
      apiClient: {
        getSessions: jest.fn(),
        createSession: jest.fn()
      },
      analytics: {
        track: jest.fn()
      },
      logger: {
        log: jest.fn(),
        error: jest.fn()
      }
    };

    TestConsumer = ({ serviceName, onServiceReceived }) => {
      const service = useService(serviceName);
      
      useEffect(() => {
        onServiceReceived(service);
      }, [service, onServiceReceived]);

      return <div data-testid={`${serviceName}-consumer`} />;
    };
  });

  it('provides services to consuming components', () => {
    const onServiceReceived = jest.fn();
    
    render(
      <ServiceContainerProvider services={mockServices}>
        <TestConsumer 
          serviceName="apiClient" 
          onServiceReceived={onServiceReceived}
        />
      </ServiceContainerProvider>
    );

    expect(onServiceReceived).toHaveBeenCalledWith(mockServices.apiClient);
  });

  it('throws error when used outside provider', () => {
    const consoleError = jest.spyOn(console, 'error').mockImplementation();

    expect(() => {
      render(<TestConsumer serviceName="apiClient" onServiceReceived={jest.fn()} />);
    }).toThrow('useService must be used within ServiceContainerProvider');

    consoleError.mockRestore();
  });

  it('resolves service dependencies correctly', () => {
    const container = new ServiceContainer();
    
    // Register services with dependencies
    container.singleton('logger', () => mockServices.logger);
    container.register('apiClient', (logger) => ({
      ...mockServices.apiClient,
      logger
    }), ['logger']);

    const onServiceReceived = jest.fn();

    render(
      <ServiceContainerContext.Provider value={container}>
        <TestConsumer 
          serviceName="apiClient" 
          onServiceReceived={onServiceReceived}
        />
      </ServiceContainerContext.Provider>
    );

    expect(onServiceReceived).toHaveBeenCalledWith(
      expect.objectContaining({
        getSessions: expect.any(Function),
        createSession: expect.any(Function),
        logger: mockServices.logger
      })
    );
  });

  it('handles circular dependencies gracefully', () => {
    const container = new ServiceContainer();
    
    container.register('serviceA', (serviceB) => ({ name: 'A' }), ['serviceB']);
    container.register('serviceB', (serviceA) => ({ name: 'B' }), ['serviceA']);

    expect(() => {
      render(
        <ServiceContainerContext.Provider value={container}>
          <TestConsumer serviceName="serviceA" onServiceReceived={jest.fn()} />
        </ServiceContainerContext.Provider>
      );
    }).toThrow('Circular dependency detected');
  });
});

// Multi-provider hierarchy testing
describe('Provider Hierarchy', () => {
  it('supports nested provider configurations', async () => {
    const TestComponent = () => {
      const config = useConfig();
      const api = useApi();
      const auth = useAuth();

      return (
        <div>
          <div data-testid="environment">{config.environment}</div>
          <div data-testid="api-url">{api.baseUrl}</div>
          <div data-testid="user-id">{auth.getCurrentUser()?.id || 'none'}</div>
        </div>
      );
    };

    const mockConfig = {
      environment: 'test',
      apiUrl: 'http://test-api.com'
    };

    const mockUser = { id: 'test-user', name: 'Test User' };

    render(
      <ConfigProvider config={mockConfig}>
        <ApiProvider>
          <AuthProvider initialUser={mockUser}>
            <TestComponent />
          </AuthProvider>
        </ApiProvider>
      </ConfigProvider>
    );

    expect(screen.getByTestId('environment')).toHaveTextContent('test');
    expect(screen.getByTestId('api-url')).toHaveTextContent('http://test-api.com');
    expect(screen.getByTestId('user-id')).toHaveTextContent('test-user');
  });

  it('isolates provider scopes correctly', () => {
    const OuterComponent = () => {
      const theme = useTheme();
      return <div data-testid="outer-theme">{theme.name}</div>;
    };

    const InnerComponent = () => {
      const theme = useTheme();
      return <div data-testid="inner-theme">{theme.name}</div>;
    };

    render(
      <ThemeProvider theme={{ name: 'light' }}>
        <OuterComponent />
        <ThemeProvider theme={{ name: 'dark' }}>
          <InnerComponent />
        </ThemeProvider>
      </ThemeProvider>
    );

    expect(screen.getByTestId('outer-theme')).toHaveTextContent('light');
    expect(screen.getByTestId('inner-theme')).toHaveTextContent('dark');
  });
});

// Provider state management testing
describe('Provider State Management', () => {
  it('maintains state consistency across re-renders', () => {
    const StateConsumer = ({ onStateChange }) => {
      const { state, dispatch } = usePracticeSession();
      
      useEffect(() => {
        onStateChange(state);
      }, [state, onStateChange]);

      return (
        <div>
          <button 
            onClick={() => dispatch({ type: 'START_SESSION' })}
            data-testid="start-session"
          >
            Start
          </button>
          <div data-testid="session-status">{state.status}</div>
        </div>
      );
    };

    const onStateChange = jest.fn();

    const { rerender } = render(
      <PracticeSessionProvider>
        <StateConsumer onStateChange={onStateChange} />
      </PracticeSessionProvider>
    );

    // Initial state
    expect(onStateChange).toHaveBeenLastCalledWith(
      expect.objectContaining({ status: 'idle' })
    );

    // Start session
    fireEvent.click(screen.getByTestId('start-session'));

    expect(onStateChange).toHaveBeenLastCalledWith(
      expect.objectContaining({ status: 'active' })
    );

    // Re-render provider
    rerender(
      <PracticeSessionProvider>
        <StateConsumer onStateChange={onStateChange} />
      </PracticeSessionProvider>
    );

    // State should be preserved
    expect(screen.getByTestId('session-status')).toHaveTextContent('active');
  });

  it('handles provider updates efficiently', () => {
    const renderCount = jest.fn();

    const TestConsumer = ({ level }) => {
      const { sessions } = usePracticeSessions();
      renderCount(`level-${level}`);
      
      return (
        <div data-testid={`level-${level}`}>
          {sessions.length} sessions
        </div>
      );
    };

    const { rerender } = render(
      <PracticeSessionProvider>
        <TestConsumer level={1} />
        <TestConsumer level={2} />
      </PracticeSessionProvider>
    );

    // Initial renders
    expect(renderCount).toHaveBeenCalledTimes(2);
    renderCount.mockClear();

    // Provider value change should trigger re-renders
    rerender(
      <PracticeSessionProvider sessions={[{ id: 1, title: 'New Session' }]}>
        <TestConsumer level={1} />
        <TestConsumer level={2} />
      </PracticeSessionProvider>
    );

    expect(renderCount).toHaveBeenCalledTimes(2);
  });
});

// Integration testing across provider boundaries
describe('Cross-Provider Integration', () => {
  it('coordinates between multiple providers', async () => {
    const IntegratedComponent = () => {
      const { createSession } = usePracticeSessions();
      const { track } = useAnalytics();
      const { show } = useNotifications();

      const handleCreateSession = async () => {
        try {
          const session = await createSession({ title: 'Test Session' });
          track('session_created', { sessionId: session.id });
          show('Session created successfully', 'success');
        } catch (error) {
          show('Failed to create session', 'error');
        }
      };

      return (
        <button onClick={handleCreateSession} data-testid="create-session">
          Create Session
        </button>
      );
    };

    const mockApi = {
      createSession: jest.fn().mockResolvedValue({ id: 'new-session', title: 'Test Session' })
    };

    const mockAnalytics = {
      track: jest.fn()
    };

    const mockNotifications = {
      show: jest.fn()
    };

    render(
      <ServiceContainerProvider services={{
        api: mockApi,
        analytics: mockAnalytics,
        notifications: mockNotifications
      }}>
        <PracticeSessionProvider>
          <IntegratedComponent />
        </PracticeSessionProvider>
      </ServiceContainerProvider>
    );

    fireEvent.click(screen.getByTestId('create-session'));

    await waitFor(() => {
      expect(mockApi.createSession).toHaveBeenCalledWith({ title: 'Test Session' });
      expect(mockAnalytics.track).toHaveBeenCalledWith('session_created', { 
        sessionId: 'new-session' 
      });
      expect(mockNotifications.show).toHaveBeenCalledWith(
        'Session created successfully',
        'success'
      );
    });
  });
});
```

:::

Testing patterns for advanced components require a deep understanding of component behavior, user workflows, and system integration. By focusing on behavior verification, using sophisticated testing utilities, and creating comprehensive integration tests, you can build confidence in complex React applications while maintaining test stability as implementations evolve. The key is to test the right things at the right level of abstraction, ensuring that tests provide value while remaining maintainable.
