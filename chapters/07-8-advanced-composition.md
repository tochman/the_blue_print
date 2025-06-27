# Advanced component composition techniques

Advanced composition techniques represent the sophisticated edge of React component architecture. These patterns transform component composition from basic JSX assembly into a refined architectural discipline that enables incredibly flexible systems while maintaining code clarity and maintainability.

These sophisticated patterns may initially appear excessive for straightforward applications. However, when building design systems, component libraries, or applications requiring extensive customization, these techniques become indispensable tools that enable component APIs to scale gracefully with evolving requirements rather than constraining development.

The fundamental principle underlying advanced composition focuses on building systems that grow with your needs rather than against them. When implemented thoughtfully, these patterns make complex customization scenarios feel intuitive and manageable while preserving code quality and developer experience.

Modern React applications benefit from composition patterns that cleanly separate concerns, enable sophisticated customization, and maintain performance while providing excellent developer experience. These patterns often eliminate complex prop drilling requirements, reduce component coupling, and create more testable, maintainable codebases.

::: important
**Composition Over Configuration Philosophy**

Advanced composition patterns favor flexible component assembly over rigid configuration approaches. By creating composable building blocks, you can construct complex interfaces from simple, well-tested components while maintaining the ability to customize behavior at any level of the component hierarchy.
:::

## Slot-based composition architecture

Slot-based composition provides a powerful alternative to traditional prop-based customization, enabling components to accept complex, nested content while maintaining clean interfaces and predictable behavior patterns.

::: example

```jsx
// Advanced slot system for flexible component composition
function createSlotSystem() {
  // Slot provider for distributing named content
  const SlotProvider = ({ slots, children }) => {
    const slotMap = useMemo(() => {
      const map = new Map();
      
      // Process slot definitions
      Object.entries(slots || {}).forEach(([name, content]) => {
        map.set(name, content);
      });

      // Extract slots from children
      React.Children.forEach(children, (child) => {
        if (React.isValidElement(child) && child.props.slot) {
          map.set(child.props.slot, child);
        }
      });

      return map;
    }, [slots, children]);

    return (
      <SlotContext.Provider value={slotMap}>
        {children}
      </SlotContext.Provider>
    );
  };

  // Slot consumer for rendering named content
  const Slot = ({ name, fallback, multiple = false, ...props }) => {
    const slots = useContext(SlotContext);
    const content = slots.get(name);

    if (!content && fallback) {
      return typeof fallback === 'function' ? fallback(props) : fallback;
    }

    if (!content) return null;

    // Handle multiple content items
    if (multiple && Array.isArray(content)) {
      return content.map((item, index) => (
        <Fragment key={index}>
          {React.isValidElement(item) ? React.cloneElement(item, props) : item}
        </Fragment>
      ));
    }

    // Single content item
    return React.isValidElement(content) 
      ? React.cloneElement(content, props) 
      : content;
  };

  return { SlotProvider, Slot };
}

const { SlotProvider, Slot } = createSlotSystem();
const SlotContext = createContext(new Map());

// Practice session card with slot-based composition
function PracticeSessionCard({ session, children, ...slots }) {
  return (
    <SlotProvider slots={slots}>
      <div className="practice-session-card">
        <header className="card-header">
          <div className="session-info">
            <h3 className="session-title">{session.title}</h3>
            <Slot 
              name="subtitle" 
              fallback={<p className="session-date">{session.date}</p>}
            />
          </div>
          
          <Slot 
            name="headerActions"
            fallback={<DefaultHeaderActions sessionId={session.id} />}
            session={session}
          />
        </header>

        <div className="card-body">
          <Slot 
            name="content"
            fallback={<DefaultSessionContent session={session} />}
            session={session}
          />
          
          <div className="session-metrics">
            <Slot 
              name="metrics"
              multiple
              session={session}
            />
          </div>
        </div>

        <footer className="card-footer">
          <Slot 
            name="footerActions"
            fallback={<DefaultFooterActions session={session} />}
            session={session}
          />
          
          <Slot name="extraContent" />
        </footer>

        {children}
      </div>
    </SlotProvider>
  );
}

// Usage with different slot configurations
function PracticeSessionList() {
  return (
    <div className="session-list">
      {sessions.map(session => (
        <PracticeSessionCard
          key={session.id}
          session={session}
          headerActions={<CustomSessionActions session={session} />}
          metrics={[
            <MetricBadge key="duration" value={session.duration} label="Duration" />,
            <MetricBadge key="score" value={session.score} label="Score" />,
            <MetricBadge key="accuracy" value={session.accuracy} label="Accuracy" />
          ]}
        >
          <SessionProgress sessionId={session.id} slot="content" />
          <ShareButton sessionId={session.id} slot="footerActions" />
        </PracticeSessionCard>
      ))}
    </div>
  );
}

// Slot-based modal system
function Modal({ isOpen, onClose, children, ...slots }) {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <SlotProvider slots={slots}>
          <div className="modal-header">
            <Slot name="title" fallback={<h2>Modal</h2>} />
            <Slot 
              name="closeButton"
              fallback={<button onClick={onClose}>X</button>}
              onClose={onClose}
            />
          </div>
          
          <div className="modal-body">
            <Slot name="content" fallback={children} />
          </div>
          
          <div className="modal-footer">
            <Slot 
              name="actions"
              fallback={<button onClick={onClose}>Close</button>}
              onClose={onClose}
            />
          </div>
        </SlotProvider>
      </div>
    </div>
  );
}

// Usage with complex customization
function SessionEditModal({ session, isOpen, onClose, onSave }) {
  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={<h2>Edit Practice Session</h2>}
      content={<SessionEditForm session={session} onSave={onSave} />}
      actions={
        <div className="modal-actions">
          <button onClick={onClose}>Cancel</button>
          <button onClick={onSave} className="primary">Save Changes</button>
        </div>
      }
    />
  );
}
```

:::

## Builder pattern for complex components

The builder pattern enables the construction of complex components through a fluent, chainable API that provides excellent developer experience and type safety.

::: example

```jsx
// Advanced component builder system
class ComponentBuilder {
  constructor(Component) {
    this.Component = Component;
    this.props = {};
    this.children = [];
    this.slots = {};
    this.middlewares = [];
  }

  // Add props with validation
  withProps(props) {
    this.props = { ...this.props, ...props };
    return this;
  }

  // Add children
  withChildren(...children) {
    this.children.push(...children);
    return this;
  }

  // Add named slots
  withSlot(name, content) {
    this.slots[name] = content;
    return this;
  }

  // Add middleware for prop transformation
  withMiddleware(middleware) {
    this.middlewares.push(middleware);
    return this;
  }

  // Conditional prop setting
  when(condition, callback) {
    if (condition) {
      callback(this);
    }
    return this;
  }

  // Build the final component
  build() {
    // Apply middlewares to transform props
    const finalProps = this.middlewares.reduce(
      (props, middleware) => middleware(props),
      { ...this.props, ...this.slots }
    );

    return React.createElement(
      this.Component,
      finalProps,
      ...this.children
    );
  }

  // Create a reusable preset
  preset(name, configuration) {
    const builder = new ComponentBuilder(this.Component);
    configuration(builder);
    
    // Store preset for reuse
    ComponentBuilder.presets = ComponentBuilder.presets || {};
    ComponentBuilder.presets[name] = configuration;
    
    return builder;
  }

  // Apply a preset
  applyPreset(name) {
    const preset = ComponentBuilder.presets?.[name];
    if (preset) {
      preset(this);
    }
    return this;
  }
}

// Practice session builder
function createPracticeSessionBuilder() {
  return new ComponentBuilder(PracticeSessionCard);
}

// Middleware for automatic prop enhancement
const withAnalytics = (props) => ({
  ...props,
  onClick: (originalOnClick) => (...args) => {
    // Track click events
    analytics.track('session_card_clicked', { sessionId: props.session?.id });
    if (originalOnClick) originalOnClick(...args);
  }
});

const withAccessibility = (props) => ({
  ...props,
  role: props.role || 'article',
  tabIndex: props.tabIndex || 0,
  'aria-label': props['aria-label'] || `Practice session: ${props.session?.title}`
});

// Usage with builder pattern
function SessionGallery({ sessions, viewMode, userRole }) {
  return (
    <div className="session-gallery">
      {sessions.map(session => {
        const builder = createPracticeSessionBuilder()
          .withProps({ session })
          .withMiddleware(withAnalytics)
          .withMiddleware(withAccessibility)
          .when(viewMode === 'detailed', builder => 
            builder
              .withSlot('metrics', <DetailedMetrics session={session} />)
              .withSlot('content', <SessionAnalysis session={session} />)
          )
          .when(viewMode === 'compact', builder =>
            builder
              .withSlot('content', <CompactSessionInfo session={session} />)
          )
          .when(userRole === 'admin', builder =>
            builder
              .withSlot('headerActions', <AdminActions session={session} />)
          );

        return builder.build();
      })}
    </div>
  );
}

// Form builder for complex forms
class FormBuilder extends ComponentBuilder {
  constructor() {
    super('form');
    this.fields = [];
    this.validation = {};
    this.sections = new Map();
  }

  addField(name, type, options = {}) {
    this.fields.push({ name, type, options });
    return this;
  }

  addSection(name, fields) {
    this.sections.set(name, fields);
    return this;
  }

  withValidation(fieldName, validator) {
    this.validation[fieldName] = validator;
    return this;
  }

  withConditionalField(fieldName, condition, field) {
    const existingField = this.fields.find(f => f.name === fieldName);
    if (existingField) {
      existingField.conditional = { condition, field };
    }
    return this;
  }

  build() {
    return (
      <DynamicForm
        fields={this.fields}
        sections={this.sections}
        validation={this.validation}
        {...this.props}
      />
    );
  }
}

// Practice session form with builder
function createSessionForm(sessionType) {
  return new FormBuilder()
    .withProps({ className: 'practice-session-form' })
    .addField('title', 'text', { required: true, label: 'Session Title' })
    .addField('duration', 'number', { required: true, min: 1, max: 240 })
    .when(sessionType === 'performance', builder =>
      builder
        .addField('piece', 'select', { 
          options: availablePieces, 
          label: 'Musical Piece' 
        })
        .addField('tempo', 'slider', { min: 60, max: 200, default: 120 })
    )
    .when(sessionType === 'technique', builder =>
      builder
        .addField('technique', 'select', { 
          options: techniques, 
          label: 'Technique Focus' 
        })
        .addField('difficulty', 'radio', { 
          options: ['Beginner', 'Intermediate', 'Advanced'] 
        })
    )
    .addField('notes', 'textarea', { optional: true })
    .withValidation('title', (value) => 
      value.length >= 3 ? null : 'Title must be at least 3 characters'
    );
}

// Layout builder for complex layouts
class LayoutBuilder {
  constructor() {
    this.structure = { type: 'container', children: [] };
    this.current = this.structure;
    this.stack = [];
  }

  row(callback) {
    const row = { type: 'row', children: [] };
    this.current.children.push(row);
    this.stack.push(this.current);
    this.current = row;
    
    if (callback) callback(this);
    
    this.current = this.stack.pop();
    return this;
  }

  col(size, callback) {
    const col = { type: 'col', size, children: [] };
    this.current.children.push(col);
    this.stack.push(this.current);
    this.current = col;
    
    if (callback) callback(this);
    
    this.current = this.stack.pop();
    return this;
  }

  component(Component, props = {}) {
    this.current.children.push({
      type: 'component',
      Component,
      props
    });
    return this;
  }

  build() {
    return <LayoutRenderer structure={this.structure} />;
  }
}

// Layout renderer component
function LayoutRenderer({ structure }) {
  const renderNode = (node, index) => {
    switch (node.type) {
      case 'container':
        return (
          <div key={index} className="layout-container">
            {node.children.map(renderNode)}
          </div>
        );
      
      case 'row':
        return (
          <div key={index} className="layout-row">
            {node.children.map(renderNode)}
          </div>
        );
      
      case 'col':
        return (
          <div key={index} className={`layout-col col-${node.size}`}>
            {node.children.map(renderNode)}
          </div>
        );
      
      case 'component':
        return <node.Component key={index} {...node.props} />;
      
      default:
        return null;
    }
  };

  return renderNode(structure, 0);
}

// Usage: Complex dashboard layout
function PracticeDashboard({ user, sessions, analytics }) {
  const layout = new LayoutBuilder()
    .row(row => row
      .col(8, col => col
        .component(WelcomeHeader, { user })
        .row(innerRow => innerRow
          .col(6, col => col
            .component(ActiveSessionCard, { session: sessions.active })
          )
          .col(6, col => col
            .component(QuickStats, { stats: analytics.today })
          )
        )
        .component(RecentSessions, { sessions: sessions.recent })
      )
      .col(4, col => col
        .component(PracticeCalendar, { sessions: sessions.all })
        .component(GoalsWidget, { goals: user.goals })
        .component(AchievementsWidget, { achievements: user.achievements })
      )
    );

  return layout.build();
}
```

:::

## Polymorphic component patterns

Polymorphic components provide ultimate flexibility by allowing the underlying element or component type to be changed while maintaining consistent behavior and styling.

::: example

```jsx
// Advanced polymorphic component implementation
function createPolymorphicComponent(defaultComponent = 'div') {
  const PolymorphicComponent = React.forwardRef(
    ({ as: Component = defaultComponent, children, ...props }, ref) => {
      return (
        <Component ref={ref} {...props}>
          {children}
        </Component>
      );
    }
  );

  // Add display name for debugging
  PolymorphicComponent.displayName = 'PolymorphicComponent';

  return PolymorphicComponent;
}

// Base polymorphic text component
const Text = React.forwardRef(({ 
  as = 'span', 
  variant = 'body',
  size = 'medium',
  weight = 'normal',
  color = 'inherit',
  children,
  className,
  ...props 
}, ref) => {
  const Component = as;
  
  const textClasses = classNames(
    'text',
    `text--${variant}`,
    `text--${size}`,
    `text--${weight}`,
    `text--${color}`,
    className
  );

  return (
    <Component ref={ref} className={textClasses} {...props}>
      {children}
    </Component>
  );
});

// Polymorphic button component with advanced features
const Button = React.forwardRef(({
  as = 'button',
  variant = 'primary',
  size = 'medium',
  loading = false,
  disabled = false,
  leftIcon,
  rightIcon,
  children,
  onClick,
  className,
  ...props
}, ref) => {
  const Component = as;
  const isDisabled = disabled || loading;

  const buttonClasses = classNames(
    'button',
    `button--${variant}`,
    `button--${size}`,
    {
      'button--loading': loading,
      'button--disabled': isDisabled
    },
    className
  );

  const handleClick = useCallback((event) => {
    if (isDisabled) {
      event.preventDefault();
      return;
    }
    
    if (onClick) {
      onClick(event);
    }
  }, [onClick, isDisabled]);

  return (
    <Component
      ref={ref}
      className={buttonClasses}
      onClick={handleClick}
      disabled={Component === 'button' ? isDisabled : undefined}
      aria-disabled={isDisabled}
      {...props}
    >
      {leftIcon && (
        <span className="button__icon button__icon--left">
          {leftIcon}
        </span>
      )}
      
      <span className="button__content">
        {loading ? <Spinner size="small" /> : children}
      </span>
      
      {rightIcon && (
        <span className="button__icon button__icon--right">
          {rightIcon}
        </span>
      )}
    </Component>
  );
});

// Polymorphic card component
const Card = React.forwardRef(({
  as = 'div',
  variant = 'default',
  padding = 'medium',
  shadow = true,
  bordered = false,
  clickable = false,
  children,
  className,
  onClick,
  ...props
}, ref) => {
  const Component = as;

  const cardClasses = classNames(
    'card',
    `card--${variant}`,
    `card--padding-${padding}`,
    {
      'card--shadow': shadow,
      'card--bordered': bordered,
      'card--clickable': clickable
    },
    className
  );

  return (
    <Component
      ref={ref}
      className={cardClasses}
      onClick={onClick}
      role={clickable ? 'button' : undefined}
      tabIndex={clickable ? 0 : undefined}
      {...props}
    >
      {children}
    </Component>
  );
});

// Practice session components using polymorphic patterns
function SessionActionButton({ session, action, ...props }) {
  // Dynamically choose component based on action type
  const getButtonProps = () => {
    switch (action.type) {
      case 'external':
        return {
          as: 'a',
          href: action.url,
          target: '_blank',
          rel: 'noopener noreferrer'
        };
      
      case 'route':
        return {
          as: Link,
          to: action.path
        };
      
      case 'download':
        return {
          as: 'a',
          href: action.downloadUrl,
          download: action.filename
        };
      
      default:
        return {
          as: 'button',
          onClick: action.handler
        };
    }
  };

  return (
    <Button
      {...getButtonProps()}
      variant={action.variant || 'secondary'}
      leftIcon={action.icon}
      {...props}
    >
      {action.label}
    </Button>
  );
}

// Polymorphic metric display
function MetricDisplay({ 
  metric, 
  as = 'div',
  interactive = false,
  size = 'medium',
  ...props 
}) {
  const baseProps = {
    className: `metric metric--${size}`,
    role: interactive ? 'button' : undefined,
    tabIndex: interactive ? 0 : undefined
  };

  if (interactive) {
    return (
      <Card
        as={as}
        clickable
        padding="small"
        {...baseProps}
        {...props}
      >
        <MetricContent metric={metric} />
      </Card>
    );
  }

  return (
    <Text
      as={as}
      variant="metric"
      {...baseProps}
      {...props}
    >
      <MetricContent metric={metric} />
    </Text>
  );
}

// Adaptive session list item
function SessionListItem({ session, viewMode, actions = [] }) {
  const getItemComponent = () => {
    switch (viewMode) {
      case 'card':
        return {
          as: Card,
          variant: 'elevated',
          clickable: true
        };
      
      case 'row':
        return {
          as: 'tr',
          className: 'session-row'
        };
      
      case 'list':
        return {
          as: 'li',
          className: 'session-list-item'
        };
      
      default:
        return {
          as: 'div',
          className: 'session-item'
        };
    }
  };

  const itemProps = getItemComponent();

  return (
    <Card {...itemProps}>
      <div className="session-header">
        <Text as="h3" variant="heading" size="small">
          {session.title}
        </Text>
        <Text variant="caption" color="muted">
          {session.date}
        </Text>
      </div>

      <div className="session-content">
        <SessionMetrics session={session} viewMode={viewMode} />
      </div>

      {actions.length > 0 && (
        <div className="session-actions">
          {actions.map((action, index) => (
            <SessionActionButton
              key={index}
              session={session}
              action={action}
              size="small"
            />
          ))}
        </div>
      )}
    </Card>
  );
}

// Usage with different contexts
function PracticeSessionsView({ sessions, viewMode }) {
  const containerProps = {
    card: { as: 'div', className: 'sessions-grid' },
    row: { as: 'table', className: 'sessions-table' },
    list: { as: 'ul', className: 'sessions-list' }
  }[viewMode] || { as: 'div' };

  return (
    <div {...containerProps}>
      {sessions.map(session => (
        <SessionListItem
          key={session.id}
          session={session}
          viewMode={viewMode}
          actions={[
            { type: 'route', path: `/sessions/${session.id}`, label: 'View' },
            { type: 'button', handler: () => editSession(session.id), label: 'Edit' }
          ]}
        />
      ))}
    </div>
  );
}
```

:::

Advanced composition techniques provide the foundation for building truly flexible and maintainable component systems. By leveraging slots, builders, and polymorphic patterns, you can create components that adapt to diverse requirements while maintaining consistency and performance. These patterns enable component libraries that feel native to React while providing the flexibility typically associated with more complex frameworks.
