# Module imports
import os;
import sys;
import json;
import datetime as dt;
from math import sqrt, pi, exp, log as ln;
from collections import defaultdict as ddict, Counter;

# Custom node types for data processing pipeline
node data_source {
    has name;
    has data = [];
}

node transformer {
    has operation;
    has parameters = {};
}

node data_sink {
    has output_type;
    has results = [];
}

node validation_node {
    has checks_passed = 0;
    has checks_failed = 0;
}

# Walkers for different processing stages
walker data_loader {
    has batch_size = 100;
    has source_file;
    
    with entry {
        # Simulate data loading
        report status "Loading data from: " + self.source_file;
        
        # Create nodes
        ds = spawn here --> node::data_source(
            name="sample_data", 
            data=[i**2 for i in range(1, 21)]
        );
        tf = spawn here --> node::transformer(operation="normalize", parameters={"method": "standard"});
        dk = spawn here --> node::data_sink(output_type="report");
        vn = spawn here --> node::validation_node();
        
        report status "Data loading completed";
        
        # Continue to next node
        take --> node::data_source;
    }
}

walker data_processor {
    has processed_count = 0;
    
    with entry {
        report status "Processing data at transformer node";
        
        # Process each item in the data
        for item in here.data {
            processed_value = self.apply_transform(item);
            report status "Processed " + str(item) + " -> " + str(processed_value);
            self.processed_count += 1;
            
            # Send to sink and validation
            take --> node::data_sink with result=processed_value;
            take --> node::validation_node with value=processed_value;
        }
        
        report status "Total processed: " + str(self.processed_count);
        take --> node::transformer;
    }
    
    can apply_transform with item {
        if here.operation == "normalize":
            return sqrt(item);
        elif here.operation == "log_transform":
            return ln(item + 1);
        else:
            return item;
    }
}

walker report_generator {
    has report_data = {};
    
    with entry {
        report status "\n=== " + here.output_type.upper() + " REPORT ===";
        report status "Generated at: " + str(dt.datetime.now());
        report status "Total items processed: " + str(len(here.results));
        report status "Sample results: " + str(here.results[:5]);
        
        # Calculate statistics
        if here.results {
            avg = sum(here.results) / len(here.results);
            report status "Average: " + str(round(avg, 2));
            report status "Max: " + str(round(max(here.results), 2));
            report status "Min: " + str(round(min(here.results), 2));
        }
        
        take --> node::data_sink;
    }
}

walker quality_checker {
    has total_checks = 0;
    
    with entry {
        report status "\nQuality Check:";
        report status "Passed: " + str(here.checks_passed) + ", Failed: " + str(here.checks_failed);
        
        if here.checks_failed == 0:
            report status "All quality checks passed!";
        else:
            report status str(here.checks_failed) + " checks failed";
        
        take --> node::validation_node;
    }
}

# Simple Age Category Checker (Your original request)
walker age_checker {
    has age;
    
    with entry {
        if !hasattr(self, 'age') or self.age == null:
            self.age = int(input("Enter your age: "));
        
        if self.age < 0:
            report status "Error: Age cannot be negative!";
        elif self.age <= 12:
            report status "You are a child (0-12)";
        elif self.age <= 19:
            report status "You are a teenager (13-19)";
        elif self.age <= 64:
            report status "You are an adult (20-64)";
        else:
            report status "You are a senior (65+)";
    }
}

# Interactive age checker walker
walker interactive_age_checker {
    with entry {
        report status "Welcome to Age Category Checker!";
        
        while true {
            age_input = input("\nHow old are you? (type 'exit' to quit): ");
            
            if age_input.lower() == "exit":
                report status "Thanks for using the Age Checker!";
                break;
            
            try {
                age = int(age_input);
                
                # Spawn age checker for this input
                spawn here walker::age_checker(age=age);
                
            } except:
                report status "Please enter a valid number!";
        }
    }
}

# Main execution block
walker init {
    with entry {
        report status "Current directory: " + str(os.getcwd());
        report status "Python version: " + str(sys.version);
        report status "Mathematical constants available";
        
        report status "\n" + "="*50;
        report status "Starting Age Checker:";
        
        # Start interactive age checker
        spawn here walker::interactive_age_checker;
    }
}