import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 12 : 8,
          height: currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index ? Colors.blueAccent : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              OnboardPage(
                image: 'assets/images/image1.png',
                title: 'Explore Nepal Easily',
                subtitle: 'Discover beautiful destinations, plan trips, and enjoy adventures.',
                screenWidth: screenWidth,
              ),
              OnboardPage(
                image: 'assets/images/image1.png',
                title: 'Plan Your Trip',
                subtitle: 'Book guides, hotels, and transport in just a few taps.',
                screenWidth: screenWidth,
              ),
              OnboardPage(
                image: 'assets/images/image1.png',
                title: 'Share Your Experience',
                subtitle: 'Rate destinations and share your adventures with the community.',
                screenWidth: screenWidth,
              ),
            ],
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: goToLogin,
              child: const Text('Skip', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                buildIndicator(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentPage == 2) {
                        goToLogin();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                      }
                    },
                    style: ElevatedButton.styleFrom(),
                    child: Text(currentPage == 2 ? 'Get Started' : 'Next', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final double screenWidth;

  const OnboardPage({super.key, required this.image, required this.title, required this.subtitle, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final imageWidth = screenWidth > 600 ? screenWidth * 0.5 : screenWidth * 0.7;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: Image.asset(image, width: imageWidth, fit: BoxFit.contain)),
          const SizedBox(height: 32),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
