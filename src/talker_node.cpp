#include "zigros_examples/producer.hpp"

int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);

  auto node_options = rclcpp::NodeOptions();  // .use_intra_process_comms(true);

  // Instantiate your application nodes.
  // This replaces your launch file.
  // all normal launch arguments can be passed using the node options
  auto talker = zigros_examples::Producer(node_options);

  auto executor = rclcpp::experimental::executors::EventsExecutor();
  executor.add_node(talker.node_.get_node_base_interface());
  executor.spin();

  rclcpp::shutdown();
}
