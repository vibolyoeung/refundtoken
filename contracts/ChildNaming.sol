// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ChildNaming {
    // Mapping to store if a name is already taken
    mapping(string => bool) private nameTaken;

    // Array to store all unique names
    string[] private names;

    // Event to emit when a new name is added
    event NameAdded(string name);

    // Function to add a name
    function addName(string calldata _name) external {
        require(!nameTaken[_name], "Name already taken");

        // Mark the name as taken
        nameTaken[_name] = true;

        // Add the name to the list of names
        names.push(_name);

        // Emit the event
        emit NameAdded(_name);
    }

    // Function to check if a name is already taken
    function isNameTaken(string calldata _name) external view returns (bool) {
        return nameTaken[_name];
    }

    // Function to get all names
    function getNames() external view returns (string[] memory) {
        return names;
    }
}
