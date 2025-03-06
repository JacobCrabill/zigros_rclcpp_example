#ifndef ZIGROS_EXAMPLES_SUBSCRIPTION_HPP
#define ZIGROS_EXAMPLES_SUBSCRIPTION_HPP

#include <geometry_msgs/msg/pose_stamped.hpp>
#include <rclcpp/rclcpp.hpp>

#include "zigros_example_interface/msg/example.hpp"
#include "zigros_example_interface/srv/example.hpp"

namespace zigros_examples
{

class Consumer
{
public:
  Consumer(rclcpp::NodeOptions options = rclcpp::NodeOptions());

  void exampleMsgCb(zigros_example_interface::msg::Example::ConstSharedPtr msg);
  void poseStampedCb(geometry_msgs::msg::PoseStamped::ConstSharedPtr msg);

  rclcpp::Node node_;

protected:
  rclcpp::Subscription<zigros_example_interface::msg::Example>::SharedPtr subscription_;
  rclcpp::Subscription<geometry_msgs::msg::PoseStamped>::SharedPtr pose_sub_;
  rclcpp::Client<zigros_example_interface::srv::Example>::SharedPtr client_;
  zigros_example_interface::msg::Example::ConstSharedPtr prev_msg_;
};
}  // namespace zigros_examples
#endif  // ZIGROS_EXAMPLES_SUBSCRIPTION_HPP
