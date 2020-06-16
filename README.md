# Flicker

Application, use to search and download and display flicker content. 
The features/highlights are,
 
1. Adopts MVVM and Observable patterns
2. Load content based on search string
3. Smooth scrolling with pagination
4. Lazy loading of the images
5. Image cache
6. TDD approach for unit tests with mocked data
7. MVVM with Coordinater Pattern

![alt text](https://github.com/run4jit/Flicker/blob/master/FlickerMobile/1_0CQ-fXv3U-pLEZw31W5fpQ.png)

The view/viewController send an event or tasks to the viewModel

The viewModel perform a task (fetch something in the backend, perform an operation, gets the model, etc.)

The viewModel notifies to viewController through: KVO, Delegates, Callbacks, Binding etc.

![alt text](https://github.com/run4jit/Flicker/blob/master/FlickerMobile/1_5nfF7o3WNQvTPttNsi2yEQ.png)

Distribution — Now our viewController doesn’t take care about the models anymore, it just send events to the view model and it perform the task, when it’s finished sends the response back to the view controller, actually the view controller doesn’t know what really happens under the hood because now it isn’t its responsibility :).

Testability — the View Model knows nothing about the View, this allows us to test it easily. The View might be also tested, but since it is UIKit dependent you might want to skip it.

Reusability — As our viewControllers doesn’t perform an specific task it’s easy to reuse a lot of code and views in the project as well as the view models.

Scalability — now the project is easy to change or update because the roles are well defined and the view controllers doesn’t perform a lot of task as before with MVC (Massive view controllers).


