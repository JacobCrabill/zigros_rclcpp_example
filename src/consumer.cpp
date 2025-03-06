#include "zigros_examples/consumer.hpp"

namespace zigros_examples
{

Consumer::Consumer(rclcpp::NodeOptions options)
: node_{"subscription", options},
  subscription_{node_.create_subscription<zigros_example_interface::msg::Example>(
    "talker/out", 1,
    [this](zigros_example_interface::msg::Example::ConstSharedPtr msg) { exampleMsgCb(msg); })},
  pose_sub_{node_.create_subscription<geometry_msgs::msg::PoseStamped>(
    "talker/pose", 1,
    [this](geometry_msgs::msg::PoseStamped::ConstSharedPtr msg) { poseStampedCb(msg); })},
  client_{node_.create_client<zigros_example_interface::srv::Example>("example")}
{
}

void Consumer::exampleMsgCb(zigros_example_interface::msg::Example::ConstSharedPtr msg)
{
  RCLCPP_INFO_STREAM(node_.get_logger(), "Time: " << msg->time.sec);
  if (prev_msg_) {
    auto request = std::make_shared<zigros_example_interface::srv::Example::Request>();
    request->a = msg->time;
    request->b = prev_msg_->time;
    client_->async_send_request(
      request, [this](rclcpp::Client<zigros_example_interface::srv::Example>::SharedFuture future) {
        if (future.valid()) {
          auto result = future.get();
          RCLCPP_INFO_STREAM(
            node_.get_logger(), "Service responce: " << rclcpp::Duration(result->diff).seconds());
        }
      });
  }
  prev_msg_ = msg;
}

void Consumer::poseStampedCb(geometry_msgs::msg::PoseStamped::ConstSharedPtr msg)
{
  RCLCPP_INFO_STREAM(
    node_.get_logger(), "Pose: " << msg->pose.position.x << ", " << msg->pose.position.y << ", "
                                 << msg->pose.position.z);
}
}  // namespace zigros_examples
