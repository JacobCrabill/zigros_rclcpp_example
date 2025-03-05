#include "zigros_examples/consumer.hpp"

int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);

  auto node_options = rclcpp::NodeOptions();  // .use_intra_process_comms(true);

  // Instantiate your application nodes.
  // This replaces your launch file.
  // all normal launch arguments can be passed using the node options
  auto listener = zigros_examples::Consumer(node_options);

  auto executor = rclcpp::experimental::executors::EventsExecutor();
  executor.add_node(listener.node_.get_node_base_interface());
  executor.spin();

  rclcpp::shutdown();
}
