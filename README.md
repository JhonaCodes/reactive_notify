

# ReactiveNotify

A powerful, elegant, and type-safe state management solution for Flutter that seamlessly integrates with the MVVM pattern while maintaining complete independence from BuildContext. Perfect for applications of any size.

[![pub package](https://img.shields.io/pub/v/reactive_notify.svg)](https://pub.dev/packages/reactive_notify)
[![likes](https://img.shields.io/pub/likes/reactive_notify?logo=dart)](https://pub.dev/packages/reactive_notify/score)
[![popularity](https://img.shields.io/pub/popularity/reactive_notify?logo=dart)](https://pub.dev/packages/reactive_notify/score)
[![license](https://img.shields.io/github/license/jhonacodes/reactive_notify.svg)](https://github.com/jhonacodes/reactive_notify/blob/master/LICENSE)

---

## 📢 Important Notice: Renamed to ReactiveNotifier

We’ve renamed this package to [`reactive_notifier`](https://pub.dev/packages/reactive_notifier) to better align with naming conventions and improve clarity. **`reactive_notify`** is now deprecated, and we strongly recommend transitioning to the updated package for future projects.

### State of the Libraries

| Package             | Status       | Version |
|---------------------|--------------|---------|
| **`reactive_notify`** | Deprecated   | 2.1.2   |
| **[`reactive_notifier`](https://pub.dev/packages/reactive_notifier)** | Active       | 2.2.0   |

The API remains unchanged, so you can upgrade to **`reactive_notifier`** seamlessly by simply updating your dependencies.

```yaml
dependencies:
  reactive_notifier: ^2.2.0
```

---

## Features

- 🚀 Simple and intuitive API
- 🏗️ Perfect for MVVM architecture
- 🔄 Independent from BuildContext
- 🎯 Type-safe state management
- 📡 Built-in Async and Stream support
- 🔗 Smart related states system
- 🛠️ Repository/Service layer integration
- ⚡ High performance with minimal rebuilds
- 🐛 Powerful debugging tools
- 📊 Detailed error reporting

## Table of Contents
- [Installation](#installation)
- [Quick Start](#quick-start)
- [State Management Patterns](#state-management-patterns)
- [MVVM Integration](#mvvm-integration)
- [Related States System](#related-states-system)
- [Async & Stream Support](#async--stream-support)
- [Debugging System](#debugging-system)
- [Best Practices](#best-practices)
- [Coming Soon](#coming-soon)
- [Contributing](#contributing)
- [License](#license)

## Installation

To continue using the deprecated package:

```yaml
dependencies:
  reactive_notify: ^2.2.0
```

To switch to the updated version:

```yaml
dependencies:
  reactive_notifier: ^2.1.2
```

---

## Quick Start

**Note:** All examples in this documentation are compatible with both **`reactive_notify`** and **`reactive_notifier`**.

### Basic Usage

```dart
// Define states globally or in a mixin
final counterState = ReactiveNotify<int>(() => 0);

// Using a mixin (recommended for organization)
mixin AppStateMixin {
  static final counterState = ReactiveNotify<int>(() => 0);
  static final userState = ReactiveNotify<UserState>(() => UserState());
}

// Use in widgets - No BuildContext needed for state management!
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder<int>(
      valueListenable: AppStateMixin.counterState,
      builder: (context, value, keep) {
        return Column(
          children: [
            Text('Count: $value'),
            keep(const CounterButtons()), // Static content preserved
          ],
        );
      },
    );
  }
}
```

## State Management Patterns

### Global State Declaration

```dart
// ✅ Correct: Global state declaration
final userState = ReactiveNotify<UserState>(() => UserState());

// ✅ Correct: Mixin with static states
mixin AuthStateMixin {
  static final authState = ReactiveNotify<AuthState>(() => AuthState());
  static final sessionState = ReactiveNotify<SessionState>(() => SessionState());
}

// ❌ Incorrect: Never create inside widgets
class WrongWidget extends StatelessWidget {
  final state = ReactiveNotify<int>(() => 0); // Don't do this!
}
```

## MVVM Integration

ReactiveNotify is built with MVVM in mind:

```dart
// 1. Repository Layer
class UserRepository implements RepositoryImpl<User> {
  final ApiNotifier apiNotifier;
  UserRepository(this.apiNotifier);
  
  Future<User> getUser() async => // Implementation
}

// 2. Service Layer (Alternative to Repository)
class UserService implements ServiceImpl<User> {
  Future<User> getUser() async => // Implementation
}

// 3. ViewModel
class UserViewModel extends ViewModelImpl<UserState> {
  UserViewModel(UserRepository repository) 
    : super(repository, UserState(), 'user-vm', 'UserScreen');
    
  @override
  void init() {
    // Automatically called on initialization
    loadUser();
  }
  
  Future<void> loadUser() async {
    try {
      final user = await repository.getUser();
      setState(UserState(name: user.name, isLoggedIn: true));
    } catch (e) {
      // Error handling
    }
  }
}

// 4. Create ViewModel Notifier
final userNotifier = ReactiveNotify<UserViewModel>(() {
  final repository = UserRepository(apiNotifier);
  return UserViewModel(repository);
});

// 5. Use in View
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder<UserViewModel>(
      valueListenable: userNotifier,
      builder: (_, viewModel, keep) {
        return Column(
          children: [
            Text('Welcome ${viewModel.state.name}'),
            keep(const UserActions()),
          ],
        );
      },
    );
  }
}
```

## Related States System

### Correct Pattern

```dart
// 1. Define individual states
final userState = ReactiveNotify<UserState>(() => UserState());
final cartState = ReactiveNotify<CartState>(() => CartState());
final settingsState = ReactiveNotify<SettingsState>(() => SettingsState());

// 2. Create relationships correctly
final appState = ReactiveNotify<AppState>(
  () => AppState(),
  related: [userState, cartState, settingsState]
);

// 3. Use in widgets - Updates automatically when any related state changes
class AppDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder<AppState>(
      valueListenable: appState,
      builder: (context, state, keep) {
        // Access related states directly
        final user = appState.from<UserState>();
        final cart = appState.from<CartState>(cartState.keyNotifier);
        
        return Column(
          children: [
            Text('Welcome ${user.name}'),
            Text('Cart Items: ${cart.items.length}'),
            if (user.isLoggedIn) keep(const UserProfile())
          ],
        );
      },
    );
  }
}
```

### What to Avoid

```dart
// ❌ NEVER: Nested related states
final cartState = ReactiveNotify<CartState>(
  () => CartState(),
  related: [userState] // ❌ Don't do this
);

// ❌ NEVER: Chain of related states
final orderState = ReactiveNotify<OrderState>(
  () => OrderState(),
  related: [cartState] // ❌ Avoid relation chains
);

// ✅ CORRECT: Flat structure with single parent
final appState = ReactiveNotify<AppState>(
  () => AppState(),
  related: [userState, cartState, orderState]
);
```

## Async & Stream Support

### Async Operations

```dart
class ProductViewModel extends AsyncViewModelImpl<List<Product>> {
  @override
  Future<List<Product>> fetchData() async {
    return await repository.getProducts();
  }
}

class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveAsyncBuilder<List<Product>>(
      viewModel: productViewModel,
      buildSuccess: (products) => ProductGrid(products),
      buildLoading: () => const LoadingSpinner(),
      buildError: (error, stack) => ErrorWidget(error),
      buildInitial: () => const InitialView(),
    );
  }
}
```

### Stream Handling

```dart
final messagesStream = ReactiveNotify<Stream<Message>>(
  () => messageRepository.getMessageStream()
);

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveStreamBuilder<Message>(
      streamNotifier: messagesStream,
      buildData: (message) => MessageBubble(message),
      buildLoading: () => const LoadingIndicator(),
      buildError: (error) => ErrorMessage(error),
      buildEmpty: () => const NoMessages(),
      buildDone: () => const StreamComplete(),
    );
  }
}
```

## Debugging System

ReactiveNotify includes a comprehensive debugging system with detailed error messages:

### Creation Tracking
```
📦 Creating ReactiveNotify<UserState>
🔗 With related types: CartState, OrderState
```

### Invalid Structure Detection
```
⚠️ Invalid Reference Structure Detected!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Current Notifier: CartState
Key: cart_key
Problem: Attempting to create a notifier with an existing key
Solution: Ensure unique keys for each notifier
Location: package:my_app/cart/cart_state.dart:42
```

### Performance Monitoring
```
⚠️ Notification Overflow Detected!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Notifier: CartState
50 notifications in 500ms
❌ Problem: Excessive updates detected
✅ Solution: Review update logic and consider debouncing
```
And more...

## Best Practices

### State Declaration
- Declare ReactiveNotify instances globally or as static mixin members
- Never create instances inside widgets
- Use mixins for better organization of related states

### Performance Optimization
- Use `keep` for static content
- Maintain flat state hierarchy
- Use keyNotifier for specific state access
- Avoid unnecessary rebuilds

### Architecture Guidelines
- Follow MVVM pattern
- Utilize Repository/Service patterns
- Let ViewModels initialize automatically
- Keep state updates context-independent

### Related States
- Maintain flat relationships
- Avoid circular dependencies
- Use type-safe access
- Keep state updates predictable

## Coming Soon: Real-Time State Inspector 🔍

We're developing a powerful visual debugging interface that will revolutionize how you debug and monitor ReactiveNotify states:

### Features in Development
- 📊 Real-time state visualization
- 🔄 Live update tracking
- 📈 Performance metrics
- 🕸️ Interactive dependency graph
- ⏱️ Update timeline
- 🔍 Deep state inspection
- 📱 DevTools integration

This tool will help you:
- Understand state flow in real-time
- Identify performance bottlenecks
- Debug complex state relationships
- Monitor rebuild patterns
- Optimize your application
- Develop more efficiently

Stay tuned for this exciting addition to ReactiveNotify!

## Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for details.

## Star Us! ⭐

If you find ReactiveNotify helpful, please star us on GitHub! It helps other developers discover this package.

## License

MIT License - see the [LICENSE](LICENSE) file for details