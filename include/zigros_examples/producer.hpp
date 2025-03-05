#ifndef ZIGROS_EXAMPLES_PUBLISHER_HPP
#define ZIGROS_EXAMPLES_PUBLISHER_HPP

#include <geometry_msgs/msg/pose_stamped.hpp>

#include "rclcpp/rclcpp.hpp"
#include "zigros_example_interface/msg/example.hpp"

namespace zigros_examples
{

class Producer
{
public:
  Producer(rclcpp::NodeOptions options = rclcpp::NodeOptions());

  rclcpp::Node node_;
  rclcpp::Publisher<zigros_example_interface::msg::Example>::SharedPtr publisher_;
  rclcpp::Publisher<geometry_msgs::msg::PoseStamped>::SharedPtr pose_pub_;
  std::shared_ptr<rclcpp::TimerBase> timer_;
};
}  // namespace zigros_examples
#endif  // ZIGROS_EXAMPLES_PUBLISHER_HPP
