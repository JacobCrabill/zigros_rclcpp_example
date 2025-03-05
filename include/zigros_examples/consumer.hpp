#ifndef ZIGROS_EXAMPLES_SUBSCRIPTION_HPP
#define ZIGROS_EXAMPLES_SUBSCRIPTION_HPP

#include "rclcpp/rclcpp.hpp"
#include "zigros_example_interface/msg/example.hpp"
#include "zigros_example_interface/srv/example.hpp"

namespace zigros_examples
{

class Consumer
{
public:
  Consumer(rclcpp::NodeOptions options = rclcpp::NodeOptions());
  rclcpp::Node node_;
  rclcpp::Subscription<zigros_example_interface::msg::Example>::SharedPtr subscription_;
  rclcpp::Client<zigros_example_interface::srv::Example>::SharedPtr client_;
  zigros_example_interface::msg::Example::ConstSharedPtr prev_msg_;
};
}  // namespace zigros_examples
#endif  // ZIGROS_EXAMPLES_SUBSCRIPTION_HPP
