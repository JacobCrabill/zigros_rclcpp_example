#include "zigros_examples/producer.hpp"

namespace zigros_examples
{

Producer::Producer(rclcpp::NodeOptions options)
: node_{"producer", options},
  publisher_{node_.create_publisher<zigros_example_interface::msg::Example>("talker/out", 1)},
  pose_pub_{node_.create_publisher<geometry_msgs::msg::PoseStamped>("talker/pose", 1)},
  timer_{
    rclcpp::create_timer(&node_, node_.get_clock(), rclcpp::Duration::from_seconds(1.0), [this]() {
      auto msg = zigros_example_interface::msg::Example();
      msg.time = node_.now();
      publisher_->publish(msg);

      geometry_msgs::msg::PoseStamped pose;
      pose.pose.position.x = 1.0;
      pose.pose.position.y = 2.0;
      pose.pose.position.z = 3.0;
      pose_pub_->publish(pose);
    })}
{
}
}  // namespace zigros_examples
