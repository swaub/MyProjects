package com.swaub.logparser;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class LogParser {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("--- Log-Parser-Lite ---");
        System.out.print("Enter path to .log file: ");
        String filePath = scanner.nextLine();

        System.out.print("Enter severity to filter (e.g., ERROR, WARN, INFO) or 'ALL': ");
        String severity = scanner.nextLine().toUpperCase();

        String outputPath = "filtered_logs.txt";

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath));
             FileWriter writer = new FileWriter(outputPath)) {

            String line;
            int count = 0;
            int total = 0;

            while ((line = reader.readLine()) != null) {
                total++;
                // Case-insensitive check without creating new string objects for every line
                if (severity.equals("ALL") || containsIgnoreCase(line, severity)) {
                    writer.write(line + System.lineSeparator());
                    count++;
                }
            }

            System.out.println("\nParsing Complete!");
            System.out.println("Total lines scanned: " + total);
            System.out.println("Lines matching '" + severity + "': " + count);
            System.out.println("Results saved to: " + outputPath);

        } catch (IOException e) {
            System.err.println("Error reading or writing file: " + e.getMessage());
        } finally {
            scanner.close();
        }
    }

    private static boolean containsIgnoreCase(String str, String searchStr) {
        if (str == null || searchStr == null) return false;
        final int length = searchStr.length();
        if (length == 0) return true;
        for (int i = str.length() - length; i >= 0; i--) {
            if (str.regionMatches(true, i, searchStr, 0, length))
                return true;
        }
        return false;
    }
}
